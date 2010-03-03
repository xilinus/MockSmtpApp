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

@synthesize toolbar = mToolbar;
@synthesize generalItem = mGeneralItem;
@synthesize tabView = mTabView;

- (void)awakeFromNib
{
    [mDefaultsController setInitialValues:[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"default.data", @"fileName",
                                           @"~/Documents/MockSMTP", @"location",
                                           [NSNumber numberWithInt:1025], @"port", nil]];
    
    [mToolbar setSelectedItemIdentifier:[mGeneralItem itemIdentifier]];
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

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    for (NSToolbarItem *item in [toolbar items])
    {
        [ids addObject:[item itemIdentifier]];
    }
    
    return ids;
}

- (IBAction)selectTab:(id)sender
{
    NSToolbarItem *item = (NSToolbarItem *)sender;
    [mTabView selectTabViewItemAtIndex:[item tag]];
}

@end
