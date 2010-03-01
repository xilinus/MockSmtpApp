//
//  TableViewController.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 18/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import "TableViewController.h"
#import "Server.h"
#import "Folder.h"
#import "Message.h"

@implementation TableViewController

- (BOOL)canDelete
{
    NSArray *messages = [self selectedObjects];
    NSUInteger count = [messages count];
    
    return count > 0;
}

- (IBAction)delete:(id)sender
{
    NSArray *messages = [self selectedObjects];
    if (![messages count])
    {
        return;
    }
    
    Message *message = [messages objectAtIndex:0];
    if (message)
    {
        Folder *folder = [message folder];
        Server *server = [folder server];
        Folder *trashFolder = [server trashFolder];
        Folder *sentFolder = [server sentFolder];
        
        if (folder == trashFolder)
        {
            [self deleteSelectionFromTrash:sender];
        }
        else if (folder == sentFolder)
        {
            [self moveSelectionToTrash:sender];
        }
    }
}

- (IBAction)moveSelectionToTrash:(id) sender
{
    NSArray *messages = [self selectedObjects];
    
    for (NSUInteger i = 0; i < [messages count]; i++)
    {
        Message *m = [messages objectAtIndex:i];
        [m setFolder:[[[m folder] server] trashFolder]];
    }
    
    [[self managedObjectContext] processPendingChanges];
}

- (IBAction)deleteSelectionFromTrash:(id) sender
{
    NSArray *messages = [self selectedObjects];
    
    for (NSUInteger i = 0; i < [messages count]; i++)
    {
        Message *m = [messages objectAtIndex:i];
        Folder *f = [m folder];
        [f removeMessagesObject:m];
    }
    
    [[self managedObjectContext] processPendingChanges];
}

- (IBAction)restoreSelectionFromTrash:(id) sender
{
    NSArray *messages = [self selectedObjects];
    
    for (NSUInteger i = 0; i < [messages count]; i++)
    {
        Message *m = [messages objectAtIndex:i];
        [m setFolder:[[[m folder] server] sentFolder]];
    }
    
    [[self managedObjectContext] processPendingChanges];
}

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    NSArray *allMessages = [self arrangedObjects];
    NSArray *messages = [allMessages objectsAtIndexes:rowIndexes];
    NSMutableArray *urls = [[NSMutableArray alloc] initWithCapacity:[messages count]];
    
    for (Message *message in messages)
    {
        NSManagedObjectID *objectId = [message objectID];
        NSURL *url = [objectId URIRepresentation];
        [urls addObject:url];
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:urls];
    [pboard declareTypes:[NSArray arrayWithObject:@"Message"] owner:self];
    [pboard setData:data forType:@"Message"];
    
    return YES;
}

@end

@implementation Folder (TableViewContent)

+ (NSSet *)keyPathsForValuesAffectingTableViewItems
{
    return [NSSet setWithObject:@"messages"];
}

- (NSSet *)tableViewItems
{
    return self.messages;
}

@end

@implementation UserProxy (TableViewContent)

+ (NSSet *)keyPathsForValuesAffectingTableViewItems
{
    return [NSSet setWithObject:@"user.messages"];
}

- (NSSet *)tableViewItems
{
    return [self.user messagesInFolder:[self folder]];
}

@end

