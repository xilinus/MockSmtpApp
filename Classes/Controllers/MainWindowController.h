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
@class TableViewController;
@class OutlineViewController;

@interface MainWindowController : NSWindowController
{
@private
    
    ServerController *mServerController;
    
    TableViewController *mTableViewController;
    OutlineViewController *mOutlineViewController;
}

- (id)init;

- (IBAction)delete:(id)sender;
- (IBAction)restore:(id)sender;

@property (nonatomic, readonly) BOOL canDelete;
@property (nonatomic, readonly) BOOL canRestore;

@property (nonatomic, assign) IBOutlet ServerController *serverController;

@property (nonatomic, assign) IBOutlet TableViewController *tableViewController;
@property (nonatomic, assign) IBOutlet OutlineViewController *outlineViewController;

@end
