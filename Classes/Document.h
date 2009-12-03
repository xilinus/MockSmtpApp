//
//  MyDocument.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 11/11/2009.
//  Copyright Natural Devices, Inc. 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainWindowController;
@class NewServerWindowController;

@interface Document : NSPersistentDocument
{
    
 @private
    NSManagedObject *_server;
    MainWindowController *mMainWindowController;
    NewServerWindowController *mNewServerWindowController;
    
    BOOL mIsNewFile;
}

- (void)save;
- (void)create;
- (void)cancel;

@property (nonatomic, assign) NSManagedObject *server;

@end
