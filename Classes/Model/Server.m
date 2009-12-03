// 
//  Server.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 12/11/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "Server.h"
#import "Folder.h"

@interface Server (Private)

- (Folder *)addFolderWithName:(NSString *)name folderId:(NSInteger)folderId;
- (Folder *)fetchFolderWithId:(NSInteger) folderId;

@end

@implementation Server 

@dynamic address;
@dynamic name;
@dynamic port;
@dynamic version;

@dynamic folders;
@dynamic users;

@dynamic sentFolder;
@dynamic trashFolder;

- (void)awakeFromInsert
{
    mSentFolder = [self addFolderWithName:NAME_FOLDER_SENT folderId:ID_FOLDER_SENT];
    mTrashFodler = [self addFolderWithName:NAME_FOLDER_TRASH folderId:ID_FOLDER_TRASH];
}

- (Folder *)sentFolder
{
    if (mSentFolder == nil)
    {
        mSentFolder = [self fetchFolderWithId:ID_FOLDER_SENT];
    }
    
    return mSentFolder;
}

- (Folder *)trashFolder
{
    if (mTrashFodler == nil)
    {
        mTrashFodler = [self fetchFolderWithId:ID_FOLDER_TRASH];
    }
    
    return mTrashFodler;
}

@end

@implementation Server (Private)

- (Folder *)addFolderWithName:(NSString *)folderName folderId:(NSInteger)folderId
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    Folder *folder = [NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:moc];
    folder.folderId = [NSNumber numberWithInt:folderId];
    folder.server = self;
    folder.name = folderName;
    
    return folder;
}

- (Folder *)fetchFolderWithId:(NSInteger) folderId
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"server == %@ and folderId == %@", self, [NSNumber numberWithInt:folderId]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    
    if ((results != nil) && ([results count] == 1) && (error == nil)) 
    {
        return [results objectAtIndex:0];
    }
    
    return nil;
}


- (NSArray*)sortDescriptors
{
    NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"outlineViewTitle" ascending:YES];
    return [NSArray arrayWithObject:desc];
}

@end
