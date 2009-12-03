//
//  MainWindowController.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 26/11/2009.
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import "MainWindowController.h"


@implementation MainWindowController

@synthesize serverController = mServerController;

- (id)init
{
    if (self = [super initWithWindowNibName:@"MainWindow"])
    {
        
    }
    
    return self;
}

- (void)windowWillClose:(NSNotification *)notification
{
    [mServerController stop:self];
}

@end
