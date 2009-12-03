//
//  SmtpSession.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 20/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SmtpConnection;
@class SmtpSessionState;

@interface SmtpSession : NSObject
{
@private

    id mDelegate;

    SmtpConnection *mConnection;
    SmtpSessionState *mState;
    
}

- (id)initWithConnection:(SmtpConnection *)connection;

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) SmtpConnection *connection;

- (void)open;
- (void)close;

- (NSUInteger)processData:(NSData *)data;

@end