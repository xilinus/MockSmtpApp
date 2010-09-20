//
//  LicenseInstallController.h
//  MockSmtp
//
//  Created by Oleg Shnitko on 15/01/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LicenseController;

@interface LicenseInstallController : NSObject
{
@private
    
    NSTextField *mFilePath;
    NSTextField *mFileInfo;
    NSTextField *mProduct;
    NSTextField *mLicenseType;
    NSTextField *mExpireText;
    NSTextField *mRegistered;
    NSTextField *mEmail;
    
    NSButton *mActivateBtn;
    
    NSPanel *mPanel;
    LicenseController *mLicenseController;
}

- (IBAction)chooseFile:(id)sender;
- (IBAction)activate:(id)sender;

@property (nonatomic, assign) IBOutlet NSTextField *filePath;
@property (nonatomic, assign) IBOutlet NSTextField *fileInfo;
@property (nonatomic, assign) IBOutlet NSTextField *product;
@property (nonatomic, assign) IBOutlet NSTextField *licenseType;
@property (nonatomic, assign) IBOutlet NSTextField *expire;
@property (nonatomic, assign) IBOutlet NSTextField *registered;
@property (nonatomic, assign) IBOutlet NSTextField *email;

@property (nonatomic, assign) IBOutlet NSButton *activateButton;
@property (nonatomic, assign) IBOutlet NSPanel *panel;
@property (nonatomic, assign) IBOutlet LicenseController *licenseController;

@end
