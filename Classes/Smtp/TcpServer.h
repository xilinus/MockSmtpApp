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

@interface TcpServer : NSObject
{
@private
    
    id mDelegate;
    
    NSString *mDomain;
    NSString *mName;
    NSString *mType;
    uint16_t mPort;
    
    CFSocketRef mIPv4socket;
    NSNetService *mNetService;
    
}

@property (nonatomic, assign) id delegate;

@property (nonatomic, retain) NSString *domain;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, assign) uint16_t port;

- (BOOL)start:(NSError **)error;
- (BOOL)stop;

- (void)handleNewConnectionFromAddress:(NSData *)address inputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;

@end

@interface TcpServer (TcpServerDelegateMethods)

- (void)tcpServer:(TcpServer *)server didReceiveConnectionFromAddress:(NSData *)address 
      inputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;

@end