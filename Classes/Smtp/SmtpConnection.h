//
//  SmtpConnection.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 20/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SmtpServer;
@class SmtpSession;

@interface SmtpConnection : NSObject
{
@private
    
    id mDelegate;
    
    SmtpServer *mServer;
    SmtpSession *mSession;
    
    NSData *mPeerAddress;
    
    NSInputStream *mInputStream;
    NSOutputStream *mOutputStream;
    
    NSMutableData *mInputBuffer;
    NSMutableData *mOutputBuffer;
    
    BOOL mIsValid;   
}

- (id)initWithPeerAddress:(NSData *)address inputStream:(NSInputStream *)inputStream
             outputStream:(NSOutputStream *)outputStream forServer:(SmtpServer *)server;

@property (nonatomic, assign) id delegate;

@property (nonatomic, readonly) SmtpServer *server;
@property (nonatomic, readonly) NSData *peerAddress;
@property (nonatomic, readonly) BOOL isValid;

- (void)writeData:(NSData *)data;
- (void)invalidate;

- (NSString *)getAddress;

@end