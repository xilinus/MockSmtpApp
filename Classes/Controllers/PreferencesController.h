//
//  PreferencesController.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 30/11/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PreferencesController : NSObject
{

@private
    
    NSPanel *mPanel;
    NSTextField *mPortField;
    NSTextField *mFileField;
    NSTextField *mLocationField;
    
    NSUserDefaultsController *mDefaultsController;
    
    NSToolbar *mToolbar;
    NSToolbarItem *mGeneralItem;
    
    NSTabView *mTabView;
}

@property (nonatomic, assign) IBOutlet NSPanel *panel;
@property (nonatomic, assign) IBOutlet NSTextField *portField;
@property (nonatomic, assign) IBOutlet NSTextField *fileField;
@property (nonatomic, assign) IBOutlet NSTextField *locationField;

@property (nonatomic, assign) IBOutlet NSUserDefaultsController *defaultsController;

@property (nonatomic, assign) IBOutlet NSToolbar *toolbar;
@property (nonatomic, assign) IBOutlet NSToolbarItem *generalItem;
@property (nonatomic, assign) IBOutlet NSTabView *tabView;

- (IBAction)chooseLocation:(id)sender;
- (IBAction)apply:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)ok:(id)sender;

- (IBAction)selectTab:(id)sender;

@end
