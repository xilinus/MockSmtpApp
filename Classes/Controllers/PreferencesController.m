//
//  PreferencesController.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 30/11/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "PreferencesController.h"


@implementation PreferencesController

@synthesize panel = mPanel;
@synthesize portField = mPortField;
@synthesize fileField = mFileField;
@synthesize locationField = mLocationField;

@synthesize defaultsController = mDefaultsController;

- (void)awakeFromNib
{
    [mDefaultsController setInitialValues:[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"default.data", @"fileName",
                                           @"~/Documents/MockSMTP", @"location",
                                           [NSNumber numberWithInt:1025], @"port", nil]];
}

- (IBAction)chooseLocation:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    
    if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton )
    {
        NSString *filename = [[openDlg filenames] objectAtIndex:0];
        [mLocationField setStringValue:filename];
        [[mDefaultsController values] setValue:filename forKey:@"location"];
    }
}

- (IBAction)apply:(id)sender
{
    [mDefaultsController save:self];
}

- (IBAction)cancel:(id)sender
{
    [mDefaultsController revert:self];
    [mPanel close];
}

- (IBAction)ok:(id)sender
{
    [mDefaultsController save:self];
    [mPanel close];
}

@end
