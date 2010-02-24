//
//  ServerFolder.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 11/11/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Server;
@class Message;

@interface Folder :  NSManagedObject  
{
@private
    
    NSNumber *mReadMessagesCount;
    NSNumber *mUnreadMessagesCount;
}

@property (nonatomic, retain) NSNumber *folderId;
@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) Server *server;

@property (readonly) NSSet *users;

@property (nonatomic, readonly) NSNumber *readMessagesCount;
@property (nonatomic, readonly) NSNumber *unreadMessagesCount;

- (void)updateReadMessagesCount;

@end

@interface Folder (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)value;
- (void)removeMessages:(NSSet *)value;

@end
