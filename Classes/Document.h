//
//  MyDocument.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 11/11/2009.
//  Copyright Natural Devices, Inc. 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainWindowController;

@interface Document : NSPersistentDocument
{
    
 @private
    NSManagedObject *_server;
    MainWindowController *mMainWindowController;
    
    BOOL mIsNewFile;
    
    NSUInteger mSelectedView;
    
    BOOL mCanSelectAll;
}

- (void)save;

- (IBAction)delete:(id)sender;

@property (nonatomic, assign) NSManagedObject *server;

@property (nonatomic, assign) NSUInteger selectedView;

@property (nonatomic, readonly) BOOL htmlViewHidden;
@property (nonatomic, readonly) BOOL bodyViewHidden;
@property (nonatomic, readonly) BOOL rawViewHidden;

@end
