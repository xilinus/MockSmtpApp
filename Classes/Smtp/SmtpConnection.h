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

#import "TcpServer.h"

@class SmtpServer;
@class SmtpSession;

@interface SmtpConnection : NSObject <SCTcpConnectionDelegate>
{
@private
    
    id mDelegate;
    
    SmtpServer *mServer;
    SmtpSession *mSession;

    NSMutableData *mInputBuffer;
    NSMutableData *mOutputBuffer;
    
    id<SCTcpConnection> mTcpConnection;
}

- (id)initWithConnection:(id<SCTcpConnection>)tcpConnection forServer:(SmtpServer *)server;

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) SmtpServer *server;

- (void)writeData:(NSData *)data;

@end