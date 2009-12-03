//
//  OutlineView.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 18/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import "OutlineView.h"

@implementation OutlineView

- (void)awakeFromNib
{
    [self setDraggingSourceOperationMask:NSDragOperationAll forLocal:YES];
    [self registerForDraggedTypes:[NSArray arrayWithObjects:@"Message", @"User", nil]];
}

-(NSMenu*)menuForEvent:(NSEvent*)event
{
	[[self window] makeFirstResponder:self];
	NSPoint menuPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	int row = [self rowAtPoint:menuPoint];
	
	BOOL currentRowIsSelected = [[self selectedRowIndexes] containsIndex:row];
	
    if (!currentRowIsSelected)
		[self selectRow:row byExtendingSelection:NO];
	
    if ([self numberOfSelectedRows] <=0)
	{
		NSMenu* tableViewMenu = [[self menu] copy];
		int i;
		for (i=0;i<[tableViewMenu numberOfItems];i++)
			[[tableViewMenu itemAtIndex:i] setEnabled:NO];
		return [tableViewMenu autorelease];
	}
	else
		return [self menu];    
}


@end
