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
#import "SmtpClient.h"

@interface TableViewController : NSArrayController
{
@private
    
    SmtpClient *mSmtpClient;
}

- (IBAction)delete:(id)sender;
- (IBAction)restore:(id)sender;
- (IBAction)copy:(id)sender;

- (IBAction)deliver:(id)sender;

- (IBAction)moveSelectionToTrash:(id)sender;
- (IBAction)deleteSelectionFromTrash:(id)sender;
- (IBAction)restoreSelectionFromTrash:(id)sender;

@property (nonatomic, readonly) BOOL canDelete;
@property (nonatomic, readonly) BOOL canRestore;
@property (nonatomic, readonly) BOOL canCopy;

@property (nonatomic, readonly) BOOL canDeliver;

@property (nonatomic, assign) IBOutlet SmtpClient *smtpClient;

@end

@protocol TableViewContent

- (NSSet *)tableViewItems;

@end

@interface Folder (TableViewContent) <TableViewContent>
@end

@interface UserProxy (TableViewContent) <TableViewContent>
@end