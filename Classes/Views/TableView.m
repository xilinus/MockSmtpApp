//
//  TableView.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 18/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import "TableView.h"


@implementation TableView

- (void)awakeFromNib
{
    [self setDraggingSourceOperationMask:NSDragOperationAll forLocal:YES];
    [self registerForDraggedTypes:[NSArray arrayWithObject:@"Message"]];
}

-(NSMenu*)menuForEvent:(NSEvent*)event
{
	[[self window] makeFirstResponder:self];
	NSPoint menuPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	int row = [self rowAtPoint:menuPoint];
	
	BOOL currentRowIsSelected = [[self selectedRowIndexes] containsIndex:row];
	
    if (!currentRowIsSelected)
		[self selectRow:row byExtendingSelection:NO];

    return [super menuForEvent:event];
}

@end
