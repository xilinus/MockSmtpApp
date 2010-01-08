//
//  SmtpConnection.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 20/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#import "SmtpConnection.h"
#import "SmtpServer.h"
#import "SmtpSession.h"

@implementation SmtpConnection

@synthesize delegate = mDelegate;
@synthesize server = mServer;

- (id)initWithConnection:(id<SCTcpConnection>)tcpConnection
               forServer:(SmtpServer *)server
{
    if (self = [super init])
    {
        mServer = server;
        mTcpConnection = tcpConnection;
        [mTcpConnection setDelegate:self];
        
        mInputBuffer = [[NSMutableData alloc] init];
        mOutputBuffer = [[NSMutableData alloc] init];
        
        mSession = [[SmtpSession alloc] initWithConnection:self];
        [mSession open];
    }
    
    return self;
}

- (void)setDelegate:(id)delegate
{
    mDelegate = delegate;
    [mSession setDelegate:delegate];
}

- (void)processIncomingBytes
{
    NSUInteger inputLength = [mInputBuffer length];
    if (inputLength > 0)
    {
        NSUInteger processed = [mSession processData:mInputBuffer];
        
        NSInteger rest = inputLength - processed;
        if (rest > 0)
        {
            memmove([mInputBuffer mutableBytes], [mInputBuffer mutableBytes] + processed, rest);
        }
        
        [mInputBuffer setLength:rest];
    }
}

- (void)processOutgoingBytes
{
    [mTcpConnection writeData:mOutputBuffer];
    [mOutputBuffer setLength:0];
}

- (void)writeData:(NSData *)data
{
    [mOutputBuffer appendData:data];
    [self processOutgoingBytes];
}

- (void)tcpConnection:(id<SCTcpConnection>)connection didReceiveData:(NSData *)data
{
    [mInputBuffer appendData:data];
    [self processIncomingBytes];
}

- (void)dealloc
{
    [super dealloc];
}

@end
