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
@synthesize messagePartController = mMessagePartController;

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

- (IBAction)restore:(id)sender
{
    NSResponder *responder = [[self window] firstResponder];
    
    if ([responder isKindOfClass:[TableView class]])
    {
        [mTableViewController restore:sender];
    }
    
    if ([responder isKindOfClass:[OutlineView class]])
    {
        [mOutlineViewController restore:sender];
    }
}

+ (NSSet *)keyPathsForValuesAffectingCanRestore
{
    return [NSSet setWithObjects:@"outlineViewController.selection", @"tableViewController.selection", nil];
}

- (BOOL)canRestore
{
    NSResponder *responder = [[self window] firstResponder];
    
    if ([responder isKindOfClass:[TableView class]])
    {
        return [mTableViewController canRestore];
    }
    
    if ([responder isKindOfClass:[OutlineView class]])
    {
        return [mOutlineViewController canRestore];
    }
    
    return NO;
}

- (IBAction)copy:(id)sender
{
    NSResponder *responder = [[self window] firstResponder];
    
    if ([responder isKindOfClass:[TableView class]])
    {
        [mTableViewController copy:sender];
    }
    
    if ([responder isKindOfClass:[OutlineView class]])
    {
        [mOutlineViewController copy:sender];
    }
}

+ (NSSet *)keyPathsForValuesAffectingCanCopy
{
    return [NSSet setWithObjects:@"outlineViewController.selection", @"tableViewController.selection", nil];
}

- (BOOL)canCopy
{
    NSResponder *responder = [[self window] firstResponder];
    
    if ([responder isKindOfClass:[TableView class]])
    {
        return [mTableViewController canCopy];
    }
    
    if ([responder isKindOfClass:[OutlineView class]])
    {
        return [mOutlineViewController canCopy];
    }
    
    NSMenuItem *item = [[NSMenuItem alloc] init];
    [item setAction:@selector(copy:)];
    return [responder validateMenuItem:item];
}

- (IBAction)deliver:(id)sender
{
    NSResponder *responder = [[self window] firstResponder];
    
    if ([responder isKindOfClass:[TableView class]])
    {
        [mTableViewController deliver:sender];
    }
    
    if ([responder isKindOfClass:[OutlineView class]])
    {
        [mOutlineViewController deliver:sender];
    }
}

+ (NSSet *)keyPathsForValuesAffectingCanDeliver
{
    return [NSSet setWithObjects:@"outlineViewController.selection", @"tableViewController.selection", nil];
}

- (BOOL)canDeliver
{
    NSResponder *responder = [[self window] firstResponder];
    
    if ([responder isKindOfClass:[TableView class]])
    {
        return [mTableViewController canDeliver];
    }
    
    if ([responder isKindOfClass:[OutlineView class]])
    {
        return [mOutlineViewController canDeliver];
    }
    
    return NO;
}

- (void)windowWillClose:(NSNotification *)notification
{
    [mServerController stop:self];
    [[self document] saveDocument:self];
}

@end
