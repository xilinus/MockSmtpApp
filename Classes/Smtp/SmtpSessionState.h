//
//  SmtpSessionState.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 20/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SmtpSession;

@interface SmtpSessionState : NSObject
{
@private
    
    id mDelegate;
    
    SmtpSessionState *mNextState;
    NSData *mResponse;
    
    NSString *mTerminator;
    NSSet *mKnownCommands;
    
@protected
    
    NSSet *mValidCommands;
    SmtpSession *mSession;
}

- (id)initWithSession:(SmtpSession *)session;
- (id)initWithSession:(SmtpSession *)session terminator:(NSString *)terminator;
- (NSUInteger)processData:(NSData *)data;

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) SmtpSession *session;
@property (nonatomic, readonly) NSData *response;
@property (nonatomic, readonly) SmtpSessionState *nextState;

@end

@interface SmtpInitState : SmtpSessionState
{
}

@end

@interface SmtpInvalidState : SmtpSessionState
{
}

@end

@interface SmtpHelloState : SmtpSessionState
{
}

@end

@interface SmtpQuitState : SmtpSessionState
{
}

@end

@interface SmtpMailState : SmtpSessionState
{
@private
    NSString *mSender;
    NSString *mReceiver;
}

- (id)initWithSession:(SmtpSession *)session sender:(NSString *)sender;

@end

@interface SmtpRcptState : SmtpSessionState
{
@private
    NSString *mSender;
    NSMutableArray *mReceivers;
}

- (id)initWithSession:(SmtpSession *)session sender:(NSString *)sender receiver:(NSString *)receiver;

@end

@interface SmtpDataState : SmtpSessionState
{
    NSString *mSender;
    NSArray *mReceivers;
    NSMutableData *mBody;
}

- (id)initWithSession:(SmtpSession *)session sender:(NSString *)sender receivers:(NSArray *)receivers;

@end

