//
//  WebViewController.h
//  TestSMTP
//
//  Created by Oleg Shnitko on 07/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface WebViewController : NSObjectController
{
@private
    WebView *_webView;
}

@property(assign) IBOutlet WebView *webView;

@end
