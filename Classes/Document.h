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
}

- (void)save;

- (IBAction)delete:(id)sender;

@property (nonatomic, assign) NSManagedObject *server;

@property (nonatomic, assign) NSUInteger selectedView;

@property (nonatomic, readonly) MainWindowController *mainWindowController;

@property (nonatomic, readonly) BOOL htmlViewHidden;
@property (nonatomic, readonly) BOOL bodyViewHidden;
@property (nonatomic, readonly) BOOL rawViewHidden;

@property (nonatomic, readonly) BOOL canDelete;
@property (nonatomic, readonly) BOOL canRestore;

- (IBAction)restore:(id)sender;

- (IBAction)showNextAlternative:(id)sender;
- (IBAction)showPrevAlternative:(id)sender;
- (IBAction)showBestAlternative:(id)sender;

@property (nonatomic, readonly) BOOL canShowNextAlternative;
@property (nonatomic, readonly) BOOL canShowPrevAlternative;
@property (nonatomic, readonly) BOOL canShowBestAlternative;

@end
