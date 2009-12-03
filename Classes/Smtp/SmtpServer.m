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
        mConnections = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)makeConnectionFromAddress:(NSData *)address 
                      inputStream:(NSInputStream *)inputStream
                     outputStream:(NSOutputStream *)outputStream
{
    SmtpConnection *connection = [[SmtpConnection alloc] initWithPeerAddress:address
                                                                 inputStream:inputStream
                                                                outputStream:outputStream
                                                                   forServer:self];
    [mConnections addObject:connection];
    [connection setDelegate:[self delegate]];

    [connection release];
}

- (void)closeConnection:(SmtpConnection *)connection
{
    if (![mConnections containsObject:connection])
    {
        return;
    }
    
    if ([connection isValid])
    {
        [connection invalidate];
        return;
    }
    
    if ([[self delegate] respondsToSelector:@selector(smtpServer:didCloseConnection:)])
    {
        [[self delegate] smtpServer:self didCloseConnection:connection];
    }
    
    [mConnections removeObject:connection];
}

- (BOOL)stop
{
    for (SmtpConnection *connection in mConnections)
    {
        [self closeConnection:connection];
    }
    
    return [super stop];
}

- (void)handleNewConnectionFromAddress:(NSData *)address
                           inputStream:(NSInputStream *)inputStream
                          outputStream:(NSOutputStream *)outputStream
{
    [super handleNewConnectionFromAddress:address inputStream:inputStream outputStream:outputStream];
    [self makeConnectionFromAddress:address inputStream:inputStream outputStream:outputStream];
}

- (void)dealloc
{
    for (SmtpConnection *connection in mConnections)
    {
        [connection invalidate];
    }
    
    [mConnections release];
    mConnections = nil;
    
    [super dealloc];
}

@end
