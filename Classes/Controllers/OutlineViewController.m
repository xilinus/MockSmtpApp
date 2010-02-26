//
//  OutlineViewController.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 18/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import "OutlineViewController.h"
#import "TableViewController.h"
#import "Server.h"
#import "Message.h"

@implementation OutlineViewController

- (IBAction)delete:(id)sender
{
    id<TableViewContent> item = [[self selectedObjects] objectAtIndex:0];
    NSArray *messages = [[item tableViewItems] allObjects];
 
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
    id<TableViewContent> item = [[self selectedObjects] objectAtIndex:0];
    NSArray *messages = [[item tableViewItems] allObjects];
    
    for (NSUInteger i = 0; i < [messages count]; i++)
    {
        Message *m = [messages objectAtIndex:i];
        [m setFolder:[[[m folder] server] trashFolder]];
    }
    
    [[self managedObjectContext] processPendingChanges];
}

- (IBAction)deleteSelectionFromTrash:(id) sender
{
    id<TableViewContent> item = [[self selectedObjects] objectAtIndex:0];
    NSArray *messages = [[item tableViewItems] allObjects];
    
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
    id<TableViewContent> item = [[self selectedObjects] objectAtIndex:0];
    NSArray *messages = [[item tableViewItems] allObjects];
    
    for (NSUInteger i = 0; i < [messages count]; i++)
    {
        Message *m = [messages objectAtIndex:i];
        [m setFolder:[[[m folder] server] sentFolder]];
    }
    
    [[self managedObjectContext] processPendingChanges];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
         writeItems:(NSArray *)items
       toPasteboard:(NSPasteboard *)pboard
{
    id item = [items objectAtIndex:0];
    item = [item valueForKey:@"observedObject"];
    
    if ([item isKindOfClass:[Folder class]])
    {
        return NO;
    }
    else if ([item isKindOfClass:[UserProxy class]])
    {
        UserProxy *proxy = (UserProxy *)item;
        User *user = [proxy user];
        Folder *folder = [proxy folder];
        
        NSMutableDictionary *urls = [[NSMutableDictionary alloc] initWithCapacity:2];
        
        NSManagedObjectID *userId = [user objectID];
        NSURL *userUrl = [userId URIRepresentation];
        [urls setObject:userUrl forKey:@"user"];
        
        NSManagedObjectID *folderId = [folder objectID];
        NSURL *folderUrl = [folderId URIRepresentation];
        [urls setObject:folderUrl forKey:@"folder"];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:urls];
        [pboard declareTypes:[NSArray arrayWithObject:@"User"] owner:self];
        [pboard setData:data forType:@"User"];
        
        return YES;
    }
    
    return NO;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView
                  validateDrop:(id < NSDraggingInfo >)info
                  proposedItem:(id)item
            proposedChildIndex:(NSInteger)index
{
    if (index != -1)
    {
        return NSDragOperationNone;
    }
    
    item = [item valueForKey:@"observedObject"];
    
    Folder *folder = nil;
    User *user = nil;
    
    if ([item isKindOfClass:[Folder class]])
    {
        folder = (Folder *)item;
    }
    else if ([item isKindOfClass:[UserProxy class]])
    {
        UserProxy *proxy = (UserProxy *)item;
        user = [proxy user];
        folder = [proxy folder];
    }
    
    if (folder == nil)
    {
        return NSDragOperationNone;
    }
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSPersistentStoreCoordinator *psc = [moc persistentStoreCoordinator];
    NSPasteboard *pasteBoard = [info draggingPasteboard];
    
    NSData *messageData = [pasteBoard dataForType:@"Message"];
    if (messageData != nil)
    {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
        NSURL *url = [array objectAtIndex:0];
        NSManagedObjectID *objectId = [psc managedObjectIDForURIRepresentation:url];
        
        Message *message = (Message *)[moc objectWithID:objectId];
        
        if (message != nil)
        {
            if ([message folder] == folder)
            {
                return NSDragOperationNone;
            }
            
            if (user != nil)
            {
                for (NSURL *url in array)
                {
                    NSManagedObjectID *objectId = [psc managedObjectIDForURIRepresentation:url];
                    Message *message = (Message *)[moc objectWithID:objectId];
                    
                    if ([message user] != user)
                    {
                        return NSDragOperationNone;
                    }
                }
            }
            
            return NSDragOperationAll;
        }
    }
    
    NSData *userData = [pasteBoard dataForType:@"User"];
    if (userData != nil)
    {
        if (user != nil)
        {
            return NSDragOperationNone;
        }
        
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        
        NSURL *folderUrl = [dict objectForKey:@"folder"];
        NSManagedObjectID *folderId = [psc managedObjectIDForURIRepresentation:folderUrl];
        Folder *dragFolder = (Folder *)[moc objectWithID:folderId];
        
        if ((dragFolder != nil) && (dragFolder != folder))
        {
            return NSDragOperationAll;
        }
    }
    
    return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
         acceptDrop:(id < NSDraggingInfo >)info
               item:(id)item
         childIndex:(NSInteger)index
{
    item = [item valueForKey:@"observedObject"];
    
    Folder *folder = nil;
    
    if ([item isKindOfClass:[Folder class]])
    {
        folder = (Folder *)item;
    }
    else if ([item isKindOfClass:[UserProxy class]])
    {
        UserProxy *proxy = (UserProxy *)item;
        folder = [proxy folder];
    }
    
    if (folder == nil)
    {
        return NO;
    }
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSPersistentStoreCoordinator *psc = [moc persistentStoreCoordinator];
    NSPasteboard *pasteBoard = [info draggingPasteboard];
    
    NSData* messageData = [pasteBoard dataForType:@"Message"];
    if (messageData != nil)
    {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
        for (NSURL *url in array)
        {
            NSManagedObjectID *objectId = [psc managedObjectIDForURIRepresentation:url];
            Message *message = (Message *)[moc objectWithID:objectId];
            [message setFolder:folder];
        }
        
        [moc processPendingChanges];
        return YES;
    }
    
    NSData *userData = [pasteBoard dataForType:@"User"];
    if (userData != nil)
    {
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        
        NSURL *userUrl = [dict objectForKey:@"user"];
        NSManagedObjectID *userId = [psc managedObjectIDForURIRepresentation:userUrl];
        User *dragUser = (User *)[moc objectWithID:userId];
        
        NSURL *folderUrl = [dict objectForKey:@"folder"];
        NSManagedObjectID *folderId = [psc managedObjectIDForURIRepresentation:folderUrl];
        Folder *dragFolder = (Folder *)[moc objectWithID:folderId];
        
        if ((dragUser != nil) && (dragFolder != nil))
        {
            NSSet *messages = [dragUser messagesInFolder:dragFolder];
            for (Message *message in messages)
            {
                [message setFolder:folder];
            }
            
            [moc processPendingChanges];
            return YES;
        }
    }    
    
    return NO;    
}

@end

@implementation Folder (OutlineViewItem)

- (BOOL)isLeaf
{
    return NO;
}

+ (NSSet *)keyPathsForValuesAffectingOutlineViewItems
{
    return [NSSet setWithObject:@"messages"];
}

- (NSSet *)outlineViewItems
{
    return [self usersFolders];
}

+ (NSSet *)keyPathsForValuesAffectingOutlineViewTitle
{
    return [NSSet setWithObject:@"address"];
}

- (NSString *)outlineViewTitle
{
    return self.name;
}

- (BOOL)isOutlineViewFontBold
{
    return YES;
}

- (NSUInteger)outlineViewFontSize
{
    return 13;
}

- (BOOL)isMoveToTrashMenuHidden
{
    return ([self.folderId intValue] == ID_FOLDER_TRASH) || ([self.messages count] == 0);
}

- (BOOL)isDeleteFromTrashMenuHidden
{
    return ([self.folderId intValue] == ID_FOLDER_SENT) || ([self.messages count] == 0);
}

- (BOOL)isRestoreFromTrashMenuHidden
{
    return ([self.folderId intValue] == ID_FOLDER_SENT) || ([self.messages count] == 0);
}

- (NSString *)moveToTrashMenuTitle
{
    return @"Move all to Trash";
}

- (NSString *)deleteFromTrashMenuTitle
{
    return @"Empty Trash";
}

- (NSString *)restoreFromTrashMenuTitle
{
    return @"Restore all";
}

@end

@implementation UserProxy (OutlineViewItem)

- (BOOL)isLeaf
{
    return YES;
}

+ (NSSet *)keyPathsForValuesAffectingOutlineViewItems
{
    return nil;
}

- (NSSet *)outlineViewItems
{
    return nil;
}

+ (NSSet *)keyPathsForValuesAffectingOutlineViewTitle
{
    return [NSSet setWithObject:@"user.address"];
}

- (NSString *)outlineViewTitle
{
    return [self.user address];
}

- (BOOL)isOutlineViewFontBold
{
    return NO;
}

- (NSUInteger)outlineViewFontSize
{
    return 11;
}

- (BOOL)isMoveToTrashMenuHidden
{
    return [self.folder isMoveToTrashMenuHidden];
}

- (BOOL)isDeleteFromTrashMenuHidden
{
    return [self.folder isDeleteFromTrashMenuHidden];
}

- (BOOL)isRestoreFromTrashMenuHidden
{
    return [self.folder isRestoreFromTrashMenuHidden];
}

- (NSString *)moveToTrashMenuTitle
{
    return @"Move to Trash";
}

- (NSString *)deleteFromTrashMenuTitle
{
    return @"Delete from Trash";
}

- (NSString *)restoreFromTrashMenuTitle
{
    return @"Restore";
}


@end




