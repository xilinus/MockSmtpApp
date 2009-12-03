//
//  SmtpSession.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 20/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import "SmtpServer.h"
#import "SmtpSession.h"
#import "SmtpConnection.h"
#import "SmtpSessionState.h"

@implementation SmtpSession

@synthesize delegate = mDelegate;
@synthesize connection = mConnection;

- (id)initWithConnection:(SmtpConnection *)connection
{
    if (self = [super init])
    {
        mConnection = connection;
    }
    
    return  self;
}

- (void)setDelegate:(id)delegate
{
    if (mDelegate != delegate)
    {
        mDelegate = delegate;
        [mState setDelegate:delegate];
    }
}

- (void)open
{
    mState = [[SmtpInitState alloc] initWithSession:self];
    [mState setDelegate:mDelegate];
    
    [mConnection writeData:[mState response]];
    
    if ([[self delegate] respondsToSelector:@selector(smtpServer:didSendResponse:inSession:forConnection:)])
    {
        [[self delegate] smtpServer:[[self connection] server]
                    didSendResponse:[mState response]
                          inSession:self
                      forConnection:[self connection]];
    }
    
    if ([mDelegate respondsToSelector:@selector(smtpServer:didOpenSession:forConnection:)])
    {
        [mDelegate smtpServer:[mConnection server] didOpenSession:self forConnection:mConnection];
    }
}

- (void)close
{
    if ([mDelegate respondsToSelector:@selector(smtpServer:didCloseSession:forConnection:)])
    {
        [mDelegate smtpServer:[mConnection server] didCloseSession:self forConnection:mConnection];
    }
}

- (NSUInteger)processData:(NSData *)data
{
    NSUInteger rest = [mState processData:data];
    NSData *response = [mState response];
    SmtpSessionState *nextState = [[mState nextState] retain];
    
    [mConnection writeData:response];
    
    if ([[self delegate] respondsToSelector:@selector(smtpServer:didSendResponse:inSession:forConnection:)])
    {
        [[self delegate] smtpServer:[[self connection] server]
                    didSendResponse:response
                          inSession:self
                      forConnection:[self connection]];
    }
    
    [mState release];
    mState = nextState;
    
    return rest;
}

- (void)dealloc
{
    [mState release];
    mState = nil;
    
    [super dealloc];
}

@end
