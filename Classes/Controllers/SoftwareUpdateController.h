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
    BOOL mIsChecked;
    BOOL mIsNewVersion;
    
    BOOL mWindowShowing;
    
    NSString *mShortStatusString;
    NSString *mStatusString;
    NSAttributedString *mUrl;
    
    WebView *mWebView;
    NSWindow *mWindow;
    
    NSUserDefaultsController *mDefaultsController;
    
    NSMutableData *mReceivedData;
    
    NSNumber *mAutoUpdate;
    
    NSTimer *mTimer;
}

@property (nonatomic, assign) BOOL isChecking;
@property (nonatomic, assign) BOOL isChecked;
@property (nonatomic, assign) BOOL isNewVersion;

@property (nonatomic, retain) NSString *shortStatusString;
@property (nonatomic, retain) NSString *statusString;
@property (nonatomic, retain) NSAttributedString *url;

@property (nonatomic, assign) IBOutlet NSUserDefaultsController *defaultsController;

@property (nonatomic, assign) IBOutlet WebView *webView;
@property (nonatomic, assign) IBOutlet NSWindow *window;

@end
