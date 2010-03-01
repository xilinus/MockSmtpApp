//
//  MainWindowController.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 26/11/2009.
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import "MainWindowController.h"
#import "TableViewController.h"
#import "OutlineViewController.h"
#import "TableView.h"
#import "OutlineView.h"

@implementation MainWindowController

@synthesize serverController = mServerController;
@synthesize tableViewController = mTableViewController;
@synthesize outlineViewController = mOutlineViewController;

- (id)init
{
    if (self = [super initWithWindowNibName:@"MainWindow"])
    {
        
    }
    
    return self;
}

- (IBAction)delete:(id)sender
{
    NSResponder *responder = [[self window] firstResponder];
    
    if ([responder isKindOfClass:[TableView class]])
    {
        [mTableViewController delete:sender];
    }
    
    if ([responder isKindOfClass:[OutlineView class]])
    {
        [mOutlineViewController delete:sender];
    }
}

+ (NSSet *)keyPathsForValuesAffectingCanDelete
{
    return [NSSet setWithObjects:@"outlineViewController.selection", @"tableViewController.selection", nil];
}

- (BOOL)canDelete
{
    NSResponder *responder = [[self window] firstResponder];
    
    if ([responder isKindOfClass:[TableView class]])
    {
        return [mTableViewController canDelete];
    }
    
    if ([responder isKindOfClass:[OutlineView class]])
    {
        return [mOutlineViewController canDelete];
    }
    
    return NO;
}

- (void)windowWillClose:(NSNotification *)notification
{
    [mServerController stop:self];
    [[self document] saveDocument:self];
}

@end
