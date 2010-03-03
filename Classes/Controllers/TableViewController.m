//
//  TableViewController.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 18/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import "TableViewController.h"
#import "Server.h"
#import "Folder.h"
#import "Message.h"
#import "MessagePart.h"

@implementation TableViewController

- (void)setSortDescriptors:(NSArray *)descriptors
{
    [super setSortDescriptors:descriptors];
    
    NSUserDefaultsController *c = [NSUserDefaultsController sharedUserDefaultsController];
    [c save:self];
}

- (BOOL)canDelete
{
    NSArray *messages = [self selectedObjects];
    NSUInteger count = [messages count];
    
    return count > 0;
}

- (BOOL)canRestore
{
    NSArray *messages = [self selectedObjects];
    NSUInteger count = [messages count];
    
    if (!count)
    {
        return NO;
    }
    
    Message *message = [messages objectAtIndex:0];
    if (message)
    {
        Folder *folder = [message folder];
        Server *server = [folder server];
        Folder *trashFolder = [server trashFolder];
        
        if (folder == trashFolder)
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)canCopy
{
    NSArray *messages = [self selectedObjects];
    NSUInteger count = [messages count];
    
    return count > 0;
}

- (IBAction)delete:(id)sender
{
    NSArray *messages = [self selectedObjects];
    if (![messages count])
    {
        return;
    }
    
    Message *message = [messages objectAtIndex:0];
    if (message)
    {
        Folder *folder = [message folder];
        Server *server = [folder server];
        Folder *trashFolder = [server trashFolder];
        Folder *sentFolder = [server sentFolder];
        
        if (folder == trashFolder)
        {
            [self deleteSelectionFromTrash:sender];
        }
        else if (folder == sentFolder)
        {
            [self moveSelectionToTrash:sender];
        }
    }
}

- (IBAction)restore:(id)sender
{
    NSArray *messages = [self selectedObjects];
    if (![messages count])
    {
        return;
    }
    
    Message *message = [messages objectAtIndex:0];
    if (message)
    {
        Folder *folder = [message folder];
        Server *server = [folder server];
        Folder *trashFolder = [server trashFolder];
        
        if (folder == trashFolder)
        {
            [self restoreSelectionFromTrash:sender];
        }
    }
}

- (IBAction)copy:(id)sender
{
    NSArray *messages = [self selectedObjects];
    if (![messages count])
    {
        return;
    }
    
    NSMutableString *string = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < [messages count]; i++)
    {
        Message *message = [messages objectAtIndex:i];
        [string appendFormat:@"Subject: %@\n", message.subject];
        [string appendFormat:@"From: %@\n", message.from];
        [string appendFormat:@"To: %@\n", message.to];
        NSString *cc = message.cc;
        if (cc)
        {
            [string appendFormat:@"Cc: %@\n", message.cc];
        }
        [string appendFormat:@"Date: %@\n", message.date];
        
        [string appendString:@"\n"];
        [string appendFormat:@"%@\n", message.bestPart.content];
    }
    
    NSPasteboard *pb = [NSPasteboard generalPasteboard]; 
    NSArray *types = [NSArray arrayWithObjects: NSStringPboardType, NSRTFPboardType, nil]; 
    [pb declareTypes:types owner:self];
    [pb setString:string forType:NSStringPboardType];
}

- (IBAction)moveSelectionToTrash:(id) sender
{
    NSArray *messages = [self selectedObjects];
    
    for (NSUInteger i = 0; i < [messages count]; i++)
    {
        Message *m = [messages objectAtIndex:i];
        [m setFolder:[[[m folder] server] trashFolder]];
    }
    
    [[self managedObjectContext] processPendingChanges];
}

- (IBAction)deleteSelectionFromTrash:(id) sender
{
    NSArray *messages = [self selectedObjects];
    
    for (NSUInteger i = 0; i < [messages count]; i++)
    {
        Message *m = [messages objectAtIndex:i];
        Folder *f = [m folder];
        [f removeMessagesObject:m];
    }
    
    [[self managedObjectContext] processPendingChanges];
}

- (IBAction)restoreSelectionFromTrash:(id) sender
{
    NSArray *messages = [self selectedObjects];
    
    for (NSUInteger i = 0; i < [messages count]; i++)
    {
        Message *m = [messages objectAtIndex:i];
        [m setFolder:[[[m folder] server] sentFolder]];
    }
    
    [[self managedObjectContext] processPendingChanges];
}

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    NSArray *allMessages = [self arrangedObjects];
    NSArray *messages = [allMessages objectsAtIndexes:rowIndexes];
    NSMutableArray *urls = [[NSMutableArray alloc] initWithCapacity:[messages count]];
    
    for (Message *message in messages)
    {
        NSManagedObjectID *objectId = [message objectID];
        NSURL *url = [objectId URIRepresentation];
        [urls addObject:url];
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:urls];
    [pboard declareTypes:[NSArray arrayWithObject:@"Message"] owner:self];
    [pboard setData:data forType:@"Message"];
    
    return YES;
}

@end

@implementation Folder (TableViewContent)

+ (NSSet *)keyPathsForValuesAffectingTableViewItems
{
    return [NSSet setWithObject:@"messages"];
}

- (NSSet *)tableViewItems
{
    return self.messages;
}

@end

@implementation UserProxy (TableViewContent)

+ (NSSet *)keyPathsForValuesAffectingTableViewItems
{
    return [NSSet setWithObject:@"user.messages"];
}

- (NSSet *)tableViewItems
{
    return [self.user messagesInFolder:[self folder]];
}

@end

