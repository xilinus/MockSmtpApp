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
    NSTextField *mTextField;
}

@property (nonatomic, assign) IBOutlet NSTextField *textField;

@end
