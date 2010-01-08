//
//  SCTcpServer.h
//  SCTcpServer
//
//  Created by Oleg Shnitko on 23/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCTcpServer;
@protocol SCTcpConnection;

@protocol SCTcpServerDelegate <NSObject>

- (void)tcpServer:(id<SCTcpServer>)server didOpenConnection:(id<SCTcpConnection>)connection;
- (void)tcpServer:(id<SCTcpServer>)server didCloseConnection:(id<SCTcpConnection>)connection;

@end

@protocol SCTcpServer <NSObject>

@property (nonatomic, assign) id<SCTcpServerDelegate> delegate;

- (BOOL)openPort:(UInt16)port;
- (void)closePort:(UInt16)port;

- (void)stop;

@end

@class SCTcpConnection;

@interface SCTcpServer : NSObject <SCTcpServer>
{
    
@private
    
    id<SCTcpServerDelegate> mDelegate;
    CFSocketRef mIPv4socket;
    
    NSMutableArray *mConnections;
    
    BOOL mIsRunning;
}

+ (id)tcpServer;

- (void)closeConnection:(SCTcpConnection *)connection;

@property (nonatomic, readonly) BOOL isRunning;

@end