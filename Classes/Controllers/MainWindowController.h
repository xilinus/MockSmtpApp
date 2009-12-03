//
//  MainWindowController.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 26/11/2009.
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ServerController;

@interface MainWindowController : NSWindowController
{
@private
    ServerController *mServerController;
}

- (id)init;

@property (nonatomic, assign) IBOutlet ServerController *serverController;

@end
