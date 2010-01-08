//
//  SmtpServer.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 19/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import "SmtpServer.h"
#import "SmtpConnection.h"

@implementation SmtpServer

- (id)init
{
    if (self = [super init])
    {
    }
    
    return self;
}

- (void)makeSmtpConnection:(id<SCTcpConnection>)tcpConnection
{
    SmtpConnection *connection = [[SmtpConnection alloc] initWithConnection:tcpConnection forServer:self];
    [connection setDelegate:[self delegate]];

    [connection release];
}

- (void)handleNewConnection:(id<SCTcpConnection>)connection
{
    [self makeSmtpConnection:connection];
}

- (void)dealloc
{
    [super dealloc];
}

@end
