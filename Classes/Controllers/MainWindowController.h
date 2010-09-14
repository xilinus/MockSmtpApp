//
//  MainWindowController.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 26/11/2009.
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "Growl.h"

@class ServerController;
@class TableViewController;
@class OutlineViewController;
@class MessagePartController;

@interface MainWindowController : NSWindowController <GrowlApplicationBridgeDelegate>
{
@private
    
    ServerController *mServerController;
    
    TableViewController *mTableViewController;
    OutlineViewController *mOutlineViewController;
    MessagePartController *mMessagePartController;
	
	NSScrollView *mScrollView;
	
	NSView *mHeaderView;
	NSCollectionView *mAttachmentsView;
	
	NSView *mContentView;
	WebView *mWebView;
	NSTextView *mTextView;
}

- (id)init;

- (IBAction)delete:(id)sender;
- (IBAction)restore:(id)sender;
- (IBAction)copy:(id)sender;

- (IBAction)deliver:(id)sender;

@property (nonatomic, readonly) BOOL canDelete;
@property (nonatomic, readonly) BOOL canRestore;
@property (nonatomic, readonly) BOOL canCopy;

@property (nonatomic, readonly) BOOL canDeliver;

@property (nonatomic, assign) IBOutlet ServerController *serverController;

@property (nonatomic, assign) IBOutlet TableViewController *tableViewController;
@property (nonatomic, assign) IBOutlet OutlineViewController *outlineViewController;
@property (nonatomic, assign) IBOutlet MessagePartController *messagePartController;

@property (nonatomic, assign) IBOutlet NSScrollView *scrollView;

@property (nonatomic, assign) IBOutlet NSView *headerView;
@property (nonatomic, assign) IBOutlet NSCollectionView *attachmentsView;

@property (nonatomic, assign) IBOutlet NSView *contentView;
@property (nonatomic, assign) IBOutlet WebView *webView;
@property (nonatomic, assign) IBOutlet NSTextView *textView;

@end
