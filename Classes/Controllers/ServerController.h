//
//  ServerController.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 19/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Server;
@class SmtpServer;
@class MainWindowController;
@class LogController;

@interface ServerController : NSObjectController
{
@private
    
    SmtpServer *mSmtpServer;
    Server *mServer;
    
    LogController *mLogController;
    
    NSToolbarItem *mStartToolbarItem;
    NSToolbarItem *mStopToolbarItem;
    NSToolbarItem *mLogToolbarItem;
    NSTextField *mStatusText;
    
    MainWindowController *mMainWindowController;
    
    BOOL mIsStarted;
    
    NSUserDefaultsController *mDefaultsController;
    NSNumber *mPort;
}

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;

@property (nonatomic, assign) IBOutlet SmtpServer *smtpServer;
@property (nonatomic, assign) IBOutlet LogController *logController;

@property (nonatomic, assign) IBOutlet NSToolbarItem *startToolbarItem;
@property (nonatomic, assign) IBOutlet NSToolbarItem *stopToolbarItem;
@property (nonatomic, assign) IBOutlet NSToolbarItem *logToolbarItem;

@property (nonatomic, assign) IBOutlet NSTextField *statusText;

@property (nonatomic, assign) IBOutlet MainWindowController *mainWindowController;
@property (nonatomic, assign) IBOutlet NSUserDefaultsController *defaultsController;

@end
