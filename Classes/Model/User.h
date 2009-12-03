//
//  User.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 12/11/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Server;
@class Folder;
@class Message;

@interface User :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString *address;

@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) Server *server;

- (NSSet *)messagesInFolder:(Folder *)folder;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)value;
- (void)removeMessages:(NSSet *)value;

@end
