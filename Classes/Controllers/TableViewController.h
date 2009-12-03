//
//  TableViewController.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 18/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "OutlineViewController.h"
#import "Message.h"

@interface TableViewController : NSArrayController
{
}

- (IBAction)moveSelectionToTrash:(id) sender;
- (IBAction)deleteSelectionFromTrash:(id) sender;
- (IBAction)restoreSelectionFromTrash:(id) sender;

@end


@protocol TableViewContent

- (NSSet *)tableViewItems;

@end

@interface Folder (TableViewContent) <TableViewContent>
@end

@interface UserProxy (TableViewContent) <TableViewContent>
@end

@protocol TableViewItem

- (BOOL)isTableViewFontBold;
- (NSUInteger)tableViewFontSize;

@end

@interface Message (TableViewItem) <TableViewItem>
@end