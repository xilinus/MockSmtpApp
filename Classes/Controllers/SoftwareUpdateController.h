//
//  SoftwareUpdateController.h
//  MockSmtp
//
//  Created by Oleg Shnitko on 06/01/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface SoftwareUpdateController : NSObject
{
@private
    
    BOOL mIsChecking;
    BOOL mIsInstalling;
    BOOL mIsProcessing;
    BOOL mIsChecked;
    BOOL mIsInstalled;
    BOOL mIsNewVersion;
    
    BOOL mWindowShowing;
    
    NSInteger mInstalledVersion;
    
    NSString *mShortStatusString;
    NSString *mStatusString;
    
    NSURL *mDownloadUrl;
    NSAttributedString *mUrl;
    
    WebView *mWebView;
    NSWindow *mWindow;
    
    NSUserDefaultsController *mDefaultsController;
    
    NSMutableData *mReceivedData;
    
    NSNumber *mAutoUpdate;
    
    NSTimer *mTimer;
    
    NSURLConnection *mUpdateConnection;
    NSURLConnection *mDownloadConnection;
}

+ (void)completeUpdateIfNeeded;

@property (nonatomic, assign) BOOL isChecking;
@property (nonatomic, assign) BOOL isInstalling;
@property (nonatomic, assign) BOOL isProcessing;
@property (nonatomic, assign) BOOL isChecked;
@property (nonatomic, assign) BOOL isInstalled;
@property (nonatomic, assign) BOOL isNewVersion;

@property (nonatomic, retain) NSString *shortStatusString;
@property (nonatomic, retain) NSString *statusString;
@property (nonatomic, retain) NSAttributedString *url;

@property (nonatomic, assign) IBOutlet NSUserDefaultsController *defaultsController;

@property (nonatomic, assign) IBOutlet WebView *webView;
@property (nonatomic, assign) IBOutlet NSWindow *window;

- (IBAction)install:(id)sender;
- (IBAction)cancel:(id)sender;

@end
