//
//  SCTcpConnection.h
//  SCTcpServer
//
//  Created by Oleg Shnitko on 23/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCTcpConnection;

@protocol SCTcpConnectionDelegate <NSObject>

- (void)tcpConnection:(id<SCTcpConnection>)connection didReceiveData:(NSData *)data;

@end

@protocol SCTcpConnection <NSObject>

@property (nonatomic, assign) id<SCTcpConnectionDelegate> delegate;

- (void)writeData:(NSData *)data;

@end

@class SCTcpServer;

@interface SCTcpConnection : NSObject <SCTcpConnection>
{
@private
    
    id mDelegate;
    
    SCTcpServer *mServer;
    
    NSData *mPeerAddress;
    
    NSInputStream *mInputStream;
    NSOutputStream *mOutputStream;
    
    NSMutableData *mInputBuffer;
    NSMutableData *mOutputBuffer;
    
    BOOL mIsValid;
}

- (id)initWithPeerAddress:(NSData *)address
              inputStream:(NSInputStream *)inputStream
             outputStream:(NSOutputStream *)outputStream
                forServer:(SCTcpServer *)server;

@property (nonatomic, readonly) SCTcpServer *server;
@property (nonatomic, readonly) NSData *peerAddress;
@property (nonatomic, readonly) BOOL isValid;

- (void)writeData:(NSData *)data;
- (void)invalidate;

- (NSString *)getAddress;

@end
