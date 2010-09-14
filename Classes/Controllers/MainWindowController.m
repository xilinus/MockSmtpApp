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

#import "Message.h"

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

- (id)init
{
    if (self = [super initWithWindowNibName:@"MainWindow"])
    {
        [GrowlApplicationBridge setGrowlDelegate:self];
    }
    
    return self;
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	
	[self.scrollView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
	[self.webView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	/*NSLog(@"key path: %@", keyPath);
	
	NSArray *subviews = [self.attachmentsView subviews];
	NSUInteger count = subviews.count;
	float subviewsWidth = 150 * count;
	float width = self.attachmentsView.frame.size.width;
	
	NSUInteger rows = round(subviewsWidth / width + 0.5);
	float height = 100 + rows * 80;
	
	NSRect frame = [[self.scrollView documentView] frame];
	if ([self.textView isHidden])
	{
		frame.size.height = MAX(NSHeight(self.scrollView.frame), height + NSHeight(self.webView.frame));
		//frame.size.width = MAX(NSWidth(self.scrollView.frame), NSWidth(self.webView.frame));
	}
	else
	{
		frame.size.height = MAX(NSHeight(self.scrollView.frame), height + NSHeight(self.textView.frame));
		//frame.size.width = NSWidth(self.scrollView.frame);
	}
	
	[[self.scrollView documentView] setFrame:frame];	
	
	frame = self.contentView.frame;
	frame.origin.y = 0;
	if (self.textView.isHidden)
	{
		frame.size.height = NSHeight(self.webView.frame);
		//frame.size.width = NSWidth(self.webView.frame);
	}
	else
	{
		frame.size.height = NSHeight(self.textView.frame);
	}
	frame.size.height = NSHeight([[self.scrollView documentView] frame]) - height;
	
	[self.contentView setFrame:frame];
	
	frame = self.textView.frame;
	frame.size.width = NSWidth(self.contentView.frame);
	self.textView.frame = frame;
	
	NSLog(@"content rect: %@", NSStringFromRect(self.contentView.frame));
	NSLog(@"web vew rect: %@", NSStringFromRect(self.webView.frame));
	NSLog(@"text view rect: %@", NSStringFromRect(self.textView.frame));
	
	frame = self.headerView.frame;
	frame.size.height = height;
	frame.origin.y = NSHeight([self.headerView superview].frame) - NSHeight(frame);
	[self.headerView setFrame:frame];
	//[[self.headerView animator] setFrame:frame];
	
	[self.webView setHidden:!self.textView.isHidden];*/
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
