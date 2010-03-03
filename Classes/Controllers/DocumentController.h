//
//  ApplicationDelegate.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 26/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Document;

@interface DocumentController : NSDocumentController
{
@private
    
    NSUserDefaultsController *mDefaultsController;
    
    NSString *mFileName;
    NSString *mLocation;
    
    Document *mDocument;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender;

@property (nonatomic, assign) IBOutlet NSUserDefaultsController *defaultsController;

@property (nonatomic, retain) Document *document;

- (IBAction)showHtml:(id)sender;
- (IBAction)showBody:(id)sender;
- (IBAction)showRaw:(id)sender;

- (IBAction)delete:(id)sender;
- (IBAction)restore:(id)sender;
- (IBAction)copy:(id)sender;

- (IBAction)showNextAlternative:(id)sender;
- (IBAction)showPrevAlternative:(id)sender;
- (IBAction)showBestAlternative:(id)sender;

@end
