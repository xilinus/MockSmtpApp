//
//  SmtpServer.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 19/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TcpServer.h"

@class SmtpConnection;
@class SmtpSession;

@interface SmtpServer : TcpServer
{
}

@end

@interface SmtpServer (SmtpServerDelegateMethods)

- (void)smtpServer:(SmtpServer *)server didOpenConnection:(SmtpConnection *)connection;
- (void)smtpServer:(SmtpServer *)server didCloseConnection:(SmtpConnection *)connection;

- (void)smtpServer:(SmtpServer *)server didOpenSession:(SmtpSession *)session forConnection:(SmtpConnection *)connection;
- (void)smtpServer:(SmtpServer *)server didCloseSession:(SmtpSession *)session forConnection:(SmtpConnection *)connection;

- (void)smtpServer:(SmtpServer *)server didReceiveCommand:(NSString *)command inSession:(SmtpSession *)session forConnection:(SmtpConnection *)connection;
- (void)smtpServer:(SmtpServer *)server didSendResponse:(NSData *)response inSession:(SmtpSession *)session forConnection:(SmtpConnection *)connection;
- (void)smtpServer:(SmtpServer *)server didReceiveMessageFrom:(NSString *)sender to:(NSArray *)receivers body:(NSData *)body inSession:(SmtpSession *)session forConnection:(SmtpConnection *)connection;

@end
