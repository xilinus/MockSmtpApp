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
#import "MessagePartController.h"

#import "TableView.h"
#import "OutlineView.h"

#import "Document.h"
#import "Message.h"
#import "MessagePart.h"

@implementation MainWindowController

@synthesize serverController = mServerController;
@synthesize tableViewController = mTableViewController;
@synthesize outlineViewController = mOutlineViewController;
@synthesize messagePartController = mMessagePartController;

@synthesize scrollView = mScrollView;

@synthesize headerView = mHeaderView;
@synthesize attachmentsView = mAttachmentsView;

@synthesize contentView = mContentView;
@synthesize webView = mWebView;
@synthesize textView = mTextView;

@synthesize bodyWebView = mBodyWebView;
@synthesize rawTextView = mRawTextView;

- (id)init
{
    if (self = [super initWithWindowNibName:@"MainWindow"])
    {
        [GrowlApplicationBridge setGrowlDelegate:self];
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
    else if ([responder isKindOfClass:[OutlineView class]])
    {
        [mOutlineViewController copy:sender];
    }
	else
	{
		Document *document = self.document;
		switch (document.selectedView)
		{
			case 0:
			{
				NSLog(@"copy html");
				MessagePart *currentPart = [self.messagePartController currentPart];
				if ([currentPart isKindOfClass:HtmlMessagePart.class])
				{
					if([[[self.webView selectedDOMRange] text] length])
					{
						[self.webView copy:self];
					}
					else
					{
						NSPasteboard *pb = [NSPasteboard generalPasteboard]; 
						NSArray *types = [NSArray arrayWithObjects: NSStringPboardType, NSRTFPboardType, nil]; 
						[pb declareTypes:types owner:self];
						[pb setString:currentPart.content forType:NSStringPboardType];
						
					}
				}
				else
				{
					NSRange selectedRange = [self.textView selectedRange];
					if (selectedRange.length)
					{
						[self.textView copy:self];
					}
					else
					{
						NSPasteboard *pb = [NSPasteboard generalPasteboard]; 
						NSArray *types = [NSArray arrayWithObjects: NSStringPboardType, NSRTFPboardType, nil]; 
						[pb declareTypes:types owner:self];
						[pb setString:currentPart.content forType:NSStringPboardType];
					}
				}
				break;
			}
			case 1:
			{
				NSLog(@"copy body");
				MessagePart *currentPart = [self.messagePartController currentPart];
				if([[[self.bodyWebView selectedDOMRange] text] length])
				{
					[self.bodyWebView copy:self];
				}
				else
				{
					NSPasteboard *pb = [NSPasteboard generalPasteboard]; 
					NSArray *types = [NSArray arrayWithObjects: NSStringPboardType, NSRTFPboardType, nil]; 
					[pb declareTypes:types owner:self];
					[pb setString:currentPart.content forType:NSStringPboardType];
				}
				break;
			}
			case 2:
			{
				NSLog(@"copy raw");
				NSRange selectedRange = [self.rawTextView selectedRange];
				if (selectedRange.length)
				{
					[self.rawTextView copy:self];
				}
				else
				{
					Message *message = [self.messagePartController content];
					NSPasteboard *pb = [NSPasteboard generalPasteboard]; 
					NSArray *types = [NSArray arrayWithObjects: NSStringPboardType, NSRTFPboardType, nil]; 
					[pb declareTypes:types owner:self];
					[pb setString:message.transferText forType:NSStringPboardType];
				}
				break;
			}
			default:
				break;
		}
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
    
	return YES;
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

- (void)growlNotificationWasClicked:(id)clickContext
{
	[self.window makeKeyAndOrderFront:self];
	[NSApp activateIgnoringOtherApps:YES];
	
	NSManagedObjectContext *moc = [self.serverController managedObjectContext];
	NSPersistentStoreCoordinator *psc = [moc persistentStoreCoordinator];
	NSManagedObjectID *messageId = [psc managedObjectIDForURIRepresentation:[NSURL URLWithString:clickContext]];
	
	Message *message = (Message *)[moc objectWithID:messageId];
	
	id arrangedObjects = [self.outlineViewController arrangedObjects];
	id messagesNode = [[arrangedObjects childNodes] objectAtIndex:0];
	
	NSArray *childNodes = [messagesNode childNodes];
	
	NSUInteger i;
	for (i = 0; i < childNodes.count; i++)
	{
		NSTreeNode *node = [childNodes objectAtIndex:i];
		id representedObject = [node representedObject];
		id user = [representedObject user];
		if (user == message.user)
		{
			break;
		}
	}
	
	NSIndexPath *path = [[NSIndexPath indexPathWithIndex:0] indexPathByAddingIndex:i];
	[self.outlineViewController setSelectionIndexPath:path];
	[self.tableViewController setSelectedObjects:[NSArray arrayWithObject:message]];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [mServerController stop:self];
    [[self document] saveDocument:self];
}

- (BOOL)windowShouldClose:(id)sender
{
	[self.window orderOut:self];
	return NO;
}

@end
