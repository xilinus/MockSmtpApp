//
//  TrialWindowController.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 05/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "TrialWindowController.h"


@implementation TrialWindowController

@synthesize textField = mTextField;

- (id)init
{
    if (self = [super initWithWindowNibName:@"TrialWindow"])
    {
        
    }
    
    return self;
}

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSApplication sharedApplication] terminate:self];
}

@end
