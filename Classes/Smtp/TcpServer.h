//
//  TcpServer.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 19/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

NSString * const TcpServerErrorDomain;

typedef enum
{
    kTcpServerCouldNotBindToIPv4Address = 1,
    kTcpServerNoSocketsAvailable = 2,
} TcpServerErrorCode;

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

@protocol SCTcpConnectionDelegate <NSObject>

- (void)tcpConnection:(id<SCTcpConnection>)connection didReceiveData:(NSData *)data;

@end

@protocol SCTcpConnection <NSObject>

@property (nonatomic, assign) id<SCTcpConnectionDelegate> delegate;

- (void)writeData:(NSData *)data;

@end

@interface TcpServer : NSObject <SCTcpServerDelegate>
{
@private
    
    id mDelegate;
    
    NSString *mDomain;
    NSString *mName;
    NSString *mType;
    uint16_t mPort;
    
    id<SCTcpServer> mServer;
}

@property (nonatomic, assign) id delegate;

@property (nonatomic, retain) NSString *domain;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, assign) uint16_t port;

- (BOOL)start:(NSError **)error;
- (BOOL)stop;

- (void)handleNewConnection:(id<SCTcpConnection>)connection;

@end