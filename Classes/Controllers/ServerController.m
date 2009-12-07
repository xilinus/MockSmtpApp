//
//  ServerController.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 19/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import "ServerController.h"

#import "SmtpServer.h"
#import "Server.h"
#import "User.h"
#import "Message.h"
#import "MainWindowController.h"

#import "EDMessage.h"

@implementation ServerController

@synthesize smtpServer = mSmtpServer;
@synthesize startToolbarItem = mStartToolbarItem;
@synthesize stopToolbarItem = mStopToolbarItem;
@synthesize logToolbarItem = mLogToolbarItem;
@synthesize statusText = mStatusText;
@synthesize mainWindowController = mMainWindowController;
@synthesize logString = mLogString;
@synthesize defaultsController = mDefaultsController;

- (void)awakeFromNib
{
    [mStartToolbarItem setEnabled:YES];
    [mStopToolbarItem setEnabled:NO];
    [mLogToolbarItem setEnabled:YES];
    
    mDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    mPort = [[mDefaultsController values] valueForKey:@"port"];
    [mDefaultsController addObserver:self forKeyPath:@"values.port" options:NSKeyValueObservingOptionNew context:nil];
    
    mServer = [[self selectedObjects] objectAtIndex:0];
    NSUInteger port = [mPort intValue];
    [mSmtpServer setPort:port];
    [mSmtpServer setDelegate:self];
    
    mLog = [[NSMutableString alloc] init];
    
    [self start:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSUInteger port = [[[mDefaultsController values] valueForKey:@"port"] intValue];
    NSUInteger savedPort = [[[mDefaultsController defaults] stringForKey:@"port"] intValue];
    
    if (port == savedPort && [mPort intValue] != savedPort)
    {
        if(mPort)
        {
            mPort = [NSNumber numberWithInt:port];
            [self stop:self];
            [self start:self];
        }
    }
}

- (void)log:(NSString *)msg
{
    [mLog appendFormat:@"%@ - %@\n", [[NSDate alloc] init], msg];
    [self setLogString:[mLog copy]];
}

- (IBAction)clearLog:(id)sender
{
    [mLog setString:@""];
    [self setLogString:[mLog copy]];
}

- (IBAction)start:(id)sender
{
    if (!mIsStarted)
    {
        NSError *error = nil;
        [self log:@"Trying to start server..."];
        NSUInteger port = [mPort intValue];
        [mSmtpServer setPort:port];
        if ([mSmtpServer start:&error])
        {
            [self log:@"Server started."];
            mIsStarted = YES;
            [mStatusText setStringValue:[NSString stringWithFormat:@"Listening on port %d", port]];
            [mStartToolbarItem setEnabled:NO];
            [mStopToolbarItem setEnabled:YES];
        }
        else
        {
            [self log:[NSString stringWithFormat:@"Error: %@", error]];
        }
    }
}

- (IBAction)stop:(id)sender
{
    if (mIsStarted)
    {
        [self log:@"Trying to stop server..."];
        if ([mSmtpServer stop])
        {
            [self log:@"Server stopped."];
            mIsStarted = NO;
            [mStatusText setStringValue:@"Server stopped"];
            [mStartToolbarItem setEnabled:YES];
            [mStopToolbarItem setEnabled:NO];
        }
    }
}

- (void)smtpServer:(SmtpServer *)server didOpenConnection:(SmtpConnection *)connection
{
    [self log:[NSString stringWithFormat:@"Connection opened: %@", connection]];
}

- (void)smtpServer:(SmtpServer *)server didCloseConnection:(SmtpConnection *)connection
{
    [self log:[NSString stringWithFormat:@"Connection closed: %@", connection]];
}

- (void)smtpServer:(SmtpServer *)server didOpenSession:(SmtpSession *)session forConnection:(SmtpConnection *)connection
{
    [self log:[NSString stringWithFormat:@"Session opened: %@", session]];
}

- (void)smtpServer:(SmtpServer *)server didCloseSession:(SmtpSession *)session forConnection:(SmtpConnection *)connection
{
    [self log:[NSString stringWithFormat:@"Session closed: %@", session]];
}

- (void)smtpServer:(SmtpServer *)server didReceiveCommand:(NSString *)command
         inSession:(SmtpSession *)session
     forConnection:(SmtpConnection *)connection
{
    [self log:[NSString stringWithFormat:@"Command received: %@", command]];
}

- (void)smtpServer:(SmtpServer *)server didSendResponse:(NSData *)response
         inSession:(SmtpSession *)session
     forConnection:(SmtpConnection *)connection
{
    NSString *str = [[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding];
    [self log:[NSString stringWithFormat:@"Sent to client: %@", [str stringByReplacingOccurrencesOfString:@"\r\n" withString:@""]]];
}

- (void)smtpServer:(SmtpServer *)aServer didReceiveMessageFrom:(NSString *)sender
                to:(NSArray *)receivers
              body:(NSData *)body
         inSession:(SmtpSession *)session
     forConnection:(SmtpConnection *)connection
{
    [self log:[NSString stringWithFormat:@"Received message from %@ with content:\n%@",
               sender, [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding]]];
    
    EDInternetMessage *imsg = [[EDInternetMessage alloc] initWithTransferData:body];
    EDCompositeContentCoder *coder = [[EDCompositeContentCoder alloc] initWithMessagePart:imsg];
    NSArray *subparts = [coder subparts];
    
    NSLog(@"%@", subparts);
    
    NSString *b = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [sender copy], @"sender",
                          [[receivers objectAtIndex:0] copy], @"receiver",
                          [b copy], @"body", nil];
    
    [self performSelectorOnMainThread:@selector(send:) withObject:dict waitUntilDone:YES];
}

- (NSString *)getSubject:(NSString *)header
{
    NSArray *headerParts = [header componentsSeparatedByString:@"\r\n"];
    
    for (NSString *part in headerParts)
    {
        if ([part hasPrefix:@"Subject: "])
        {
            return [part substringFromIndex:9];
        }
    }
    
    return nil;
}

- (void)send:(NSDictionary *)dict
{
    NSString *sender = [dict objectForKey:@"sender"];
    NSString *receiver = [dict objectForKey:@"receiver"];
    NSString *rawBody = [dict objectForKey:@"body"];
    
    sender = [sender stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    receiver = [receiver stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    NSRange range = [rawBody rangeOfString:@"\r\n\r\n"];
    
    NSString *subject = nil;
    NSString *body = rawBody;
    
    if (range.length > 0 && range.location > 0)
    {
        NSString *bodyHeader = [rawBody substringToIndex:range.location];
        body = [rawBody substringFromIndex:range.location + range.length];
    
        subject = [self getSubject:bodyHeader];
    }
    
    if (subject == nil)
    {
        subject = @"";
        body = rawBody;
    }
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSError *fetchError = nil;
    NSArray *fetchResults;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                         inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address == %@", sender];
    [fetchRequest setPredicate:predicate];
    
    fetchError = nil;
    fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
    
    User *user = nil;
    
    if ((fetchResults != nil) && ([fetchResults count] == 1) && (fetchError == nil)) 
    {
        user = [fetchResults objectAtIndex:0];
    }
    else
    {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc];
        [user setServer:mServer];
        [user setAddress:sender];
        [moc processPendingChanges];
    }
    
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:moc];
    [message setReceiver:receiver];
    [message setSubject:subject];
    [message setBody:body];
    [message setRawData:rawBody];
    [message setUser:user];
    [message setFolder:[mServer sentFolder]];
    
    [moc processPendingChanges];
    [[mMainWindowController document] saveDocument:self];
}

@end
