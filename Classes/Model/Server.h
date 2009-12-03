//
//  Server.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 12/11/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import <CoreData/CoreData.h>

#define ID_FOLDER_SENT 0
#define ID_FOLDER_TRASH 1

#define NAME_FOLDER_SENT @"Mailboxes"
#define NAME_FOLDER_TRASH @"Trash"

@class Folder;

@interface Server :  NSManagedObject  
{
@private

    Folder *mSentFolder;
    Folder *mTrashFodler;
    
}

@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *port;
@property (nonatomic, retain) NSNumber *version;

@property (nonatomic, retain) NSSet *folders;
@property (nonatomic, retain) NSSet *users;

@property (nonatomic, readonly) Folder *sentFolder;
@property (nonatomic, readonly) Folder *trashFolder;

@end
