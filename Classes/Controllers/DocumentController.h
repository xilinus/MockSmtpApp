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

@interface DocumentController : NSDocumentController
{
@private
    
    NSUserDefaultsController *mDefaultsController;
    
    NSString *mFileName;
    NSString *mLocation;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender;

@property (nonatomic, assign) IBOutlet NSUserDefaultsController *defaultsController;

@end
