//
//  SmtpSessionState.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 20/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import "SmtpSessionState.h"
#import "SmtpServer.h"
#import "SmtpConnection.h"
#import "SmtpSession.h"

@implementation SmtpSessionState

@synthesize delegate = mDelegate;
@synthesize session = mSession;
@synthesize response = mResponse;
@synthesize nextState = mNextState;

- (id)initWithSession:(SmtpSession *)session terminator:(NSString *)terminator
{
    if (self = [super init])
    {
        mSession = session;
        mTerminator = [terminator copy];
        mNextState = self;
        mKnownCommands = [[NSSet alloc] initWithObjects:@"HELO", @"helo", @"EHLO", @"ehlo", @"MAIL", @"mail", @"RCPT", @"rcpt", @"DATA", @"data", @"RSET", @"rset", @"QUIT", @"quit", @"NOOP", @"noop", nil];
    }
    
    return self;
}

- (id)initWithSession:(SmtpSession *)session
{
    if (self = [self initWithSession:session terminator:@"\r\n"])
    {
    }
    
    return self;
}

- (void)setDelegate:(id)delegate
{
    mDelegate = delegate;
    
    if (mNextState != self)
    {
        [mNextState setDelegate:delegate];
    }
}

- (BOOL)knowCommand:(NSString *)command
{
    return [mKnownCommands containsObject:command];
}

- (BOOL)validCommand:(NSString *)command
{
    return [mValidCommands containsObject:command];
}

- (void)setStringResponse:(NSString *)response
{
    [mResponse release];
    mResponse = [[NSData alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)setOkResponse
{
    [self setStringResponse:@"250 OK\r\n"];
}

- (void)setNextState:(SmtpSessionState *)state
{
    if (mNextState != state)
    {
        if (mNextState != self)
        {
            [mNextState release];
        }
        
        mNextState = state;
        
        if (mNextState != self)
        {
            [mNextState retain];
        }
        
        [mNextState setDelegate:mDelegate];
    }
}

- (void)setInvalidState
{
    SmtpSessionState *state = [[SmtpInvalidState alloc] initWithSession:mSession];
    [self setNextState:state];
    [state release];
}

- (void)processNOOP
{
    [self setOkResponse];
}

- (void)processRSET
{
    [self setOkResponse];
    
    SmtpSessionState *state = [[SmtpInitState alloc] initWithSession:mSession];
    [self setNextState:state];
    [state release];    
}

- (void)processCommand:(NSString *)command withArgs:(NSArray *)array
{
}

- (void)processCommand:(NSString *)commandString
{
    if ([[self delegate] respondsToSelector:@selector(smtpServer:didReceiveCommand:inSession:forConnection:)])
    {
        [[self delegate] smtpServer:[[mSession connection] server]
                  didReceiveCommand:commandString
                          inSession:mSession
                      forConnection:[mSession connection]];
    }
    
    NSArray *tokens = [commandString componentsSeparatedByString:@" "];
    NSString *command = [tokens objectAtIndex:0];
    
    if (![self knowCommand:command])
    {
        [self setStringResponse:@"500 command not recognized\r\n"];
        [self setInvalidState];
        return;
    }
    
    if (![self validCommand:command])
    {
        [self setStringResponse:@"503 bad sequence of commands"];
        [self setInvalidState];
        return;
    }
    
    NSMutableArray *args = [tokens mutableCopy];
    [args removeObjectAtIndex:0];
    
    [self processCommand:command withArgs:args];
    
    [args release];
    [tokens release];
}

- (NSUInteger)processData:(NSData *)data
{
    NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSUInteger processed = 0;
    
    if ([stringData hasSuffix:mTerminator])
    {
        [self processCommand:[stringData stringByReplacingOccurrencesOfString:mTerminator withString:@""]];
        processed = [data length];
    }
    
    [stringData release];
    
    return processed;
}

- (void)dealloc
{
    [mResponse release];
    mResponse = nil;
    
    if (mNextState != self)
    {
        [mNextState release];
    }
    mNextState = nil;
    
    [mTerminator release];
    mTerminator = nil;
    
    [mKnownCommands release];
    mKnownCommands = nil;
    
    [mValidCommands release];
    mValidCommands = nil;
    
    [super dealloc];
}

@end

@implementation SmtpInitState

- (id)initWithSession:(SmtpSession *)session
{
    if (self = [super initWithSession:session])
    {
        mValidCommands = [[NSSet alloc] initWithObjects:@"HELO", @"helo", @"EHLO", @"ehlo", nil];
        [self setStringResponse:@"220 Xilinus Simple Mail Transfer Testing Service Ready\r\n"];
    }
    
    return self;
}

- (void)processCommand:(NSString *)command withArgs:(NSArray *)array
{
    if ([command isEqualTo:@"HELO"] || [command isEqualTo:@"helo"])
    {
        [self setOkResponse];
        
        SmtpSessionState *state = [[SmtpHelloState alloc] initWithSession:mSession];
        [self setNextState:state];
        [state release];
        
        return;
    }
    
    if ([command isEqualTo:@"EHLO"] || [command isEqualTo:@"ehlo"])
    {
        [self setStringResponse:@"250-[127.0.0.1]\r\n250 EHLO\r\n"];
        
        SmtpSessionState *state = [[SmtpHelloState alloc] initWithSession:mSession];
        [self setNextState:state];
        [state release];
        
        return;
    }
}

@end

@implementation SmtpInvalidState

- (id)initWithSession:(SmtpSession *)session
{
    if (self = [super initWithSession:session])
    {
        mValidCommands = [[NSSet alloc] initWithObjects:@"RSET", @"rset", @"HELO", @"helo", @"EHLO", @"ehlo", nil];
    }
    
    return self;
}

- (void)processCommand:(NSString *)command withArgs:(NSArray *)array
{
    if ([command isEqualTo:@"HELO"] || [command isEqualTo:@"helo"])
    {
        [self setOkResponse];
        
        SmtpSessionState *state = [[SmtpHelloState alloc] initWithSession:mSession];
        [self setNextState:state];
        [state release];
        
        return;
    }
    
    if ([command isEqualTo:@"EHLO"] || [command isEqualTo:@"ehlo"])
    {
        [self setStringResponse:@"250-[127.0.0.1]\r\n250 EHLO\r\n"];
        
        SmtpSessionState *state = [[SmtpHelloState alloc] initWithSession:mSession];
        [self setNextState:state];
        [state release];
        
        return;
    }
    
    [self processRSET];
}

@end

@implementation SmtpHelloState

- (id)initWithSession:(SmtpSession *)session
{
    if (self = [super initWithSession:session])
    {
        mValidCommands = [[NSSet alloc] initWithObjects:@"MAIL", @"mail", @"RSET", @"rset", @"NOOP", @"noop", @"QUIT", @"quit", nil];
    }
    
    return self;
}

- (void)processCommand:(NSString *)command withArgs:(NSArray *)args
{
    if ([command isEqualToString:@"RSET"] || [command isEqualToString:@"rset"])
    {
        [self processRSET];
        return;
    }
    
    if ([command isEqualToString:@"NOOP"] || [command isEqualToString:@"noop"])
    {
        [self processNOOP];
        return;
    }
    
    if ([command isEqualToString:@"QUIT"] || [command isEqualToString:@"quit"])
    {
        [self setOkResponse];
        return;
    }
    
    [self setOkResponse];
    
    NSString *fromArg = [args objectAtIndex:0];
    NSArray *a = [fromArg componentsSeparatedByString:@":"];
    
    SmtpSessionState *state = [[SmtpMailState alloc] initWithSession:mSession sender:[a lastObject]];
    
    [self setNextState:state];
    [state release];
}

@end

@implementation SmtpMailState

- (id)initWithSession:(SmtpSession *)session sender:(NSString *)sender
{
    if (self = [super initWithSession:session])
    {
        mSender = [sender copy];
        mValidCommands = [[NSSet alloc] initWithObjects:@"RCPT", @"rcpt", @"RSET", @"rset", @"NOOP", @"noop", nil];
    }
    
    return self;
}

- (void)processCommand:(NSString *)command withArgs:(NSArray *)args
{
    if ([command isEqualToString:@"RSET"] || [command isEqualToString:@"rset"])
    {
        [self processRSET];
        return;
    }
    
    if ([command isEqualToString:@"NOOP"] || [command isEqualToString:@"noop"])
    {
        [self processNOOP];
        return;
    }
    
    [self setOkResponse];
    
    NSString *rcptArg = [args objectAtIndex:0];
    NSArray *a = [rcptArg componentsSeparatedByString:@":"];
    
    SmtpSessionState *state = [[SmtpRcptState alloc] initWithSession:mSession sender:mSender receiver:[a lastObject]];
    
    [self setNextState:state];
    [state release];
}

- (void)dealloc
{
    [mSender release];
    mSender = nil;
    
    [mReceiver release];
    mReceiver = nil;
    
    [super dealloc];
}

@end

@implementation SmtpRcptState

- (id)initWithSession:(SmtpSession *)session sender:(NSString *)sender receiver:(NSString *)receiver
{
    if (self = [super initWithSession:session])
    {
        mSender = [sender copy];
        mReceivers = [[NSMutableArray alloc] initWithObjects:receiver, nil];
        mValidCommands = [[NSSet alloc] initWithObjects:@"RCPT", @"rcpt", @"DATA", @"data", @"RSET", @"rset", @"NOOP", @"noop", nil];
    }
    
    return self;
}

- (void)processCommand:(NSString *)command withArgs:(NSArray *)args
{
    if ([command isEqualToString:@"RSET"] || [command isEqualToString:@"rset"])
    {
        [self processRSET];
        return;
    }
    
    if ([command isEqualToString:@"NOOP"] || [command isEqualToString:@"noop"])
    {
        [self processNOOP];
        return;
    }
    
    if ([command isEqualToString:@"RCPT"] || [command isEqualToString:@"rcpt"])
    {
        [self setOkResponse];
        
        NSString *rcptArg = [args objectAtIndex:0];
        NSArray *a = [rcptArg componentsSeparatedByString:@":"];
        
        [mReceivers addObject:[a lastObject]];
        return;
    }
    
    [self setStringResponse:@"354 Start mail input; end with <CRLF>.<CRLF>\r\n"];
    
    SmtpSessionState *state = [[SmtpDataState alloc] initWithSession:mSession sender:mSender receivers:mReceivers];
    
    [self setNextState:state];
    [state release];
}

- (void)dealloc
{
    [mSender release];
    mSender = nil;
    
    [mReceivers release];
    mReceivers = nil;
    
    [super dealloc];
}

@end

@implementation SmtpDataState

- (id)initWithSession:(SmtpSession *)session sender:(NSString *)sender receivers:(NSArray *)receivers
{
    if (self = [super initWithSession:session terminator:@"\r\n.\r\n"])
    {
        mSender = [sender copy];
        mReceivers = [[NSArray alloc] initWithArray:receivers];
        mBody = [[NSMutableData alloc] init];
    }
    
    return self;
}

- (void)processCommand:(NSString *)commandString
{
    NSString *body = [commandString stringByReplacingOccurrencesOfString:@"\r\n..\r\n" withString:@"\r\n.\r\n"];
    NSData *d = [body dataUsingEncoding:NSUTF8StringEncoding];
    [mBody appendData:d];
    
    [self setOkResponse];
    
    SmtpSessionState *state = [[SmtpHelloState alloc] initWithSession:mSession];
    [self setNextState:state];
    [state release];
    
    if ([[self delegate] respondsToSelector:@selector(smtpServer:didReceiveMessageFrom:to:body:inSession:forConnection:)])
    {
        [[self delegate] smtpServer:[[mSession connection] server]
              didReceiveMessageFrom:mSender
                                 to:mReceivers
                               body:mBody
                          inSession:mSession
                      forConnection:[mSession connection]];
    }
}

- (void)dealloc
{
    [mSender release];
    mSender = nil;
    
    [mReceivers release];
    mReceivers = nil;
    
    [mBody release];
    mBody = nil;
    
    [super dealloc];
}

@end

@implementation SmtpQuitState

@end
