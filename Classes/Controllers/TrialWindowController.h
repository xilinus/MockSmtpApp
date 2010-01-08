//
//  TrialWindowController.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 05/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TrialWindowController : NSWindowController
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
}

+ (BOOL)checkLicense;
+ (BOOL)installDefaultLicenseFile;

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

@end
