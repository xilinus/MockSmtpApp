// 
//  ServerFolder.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 11/11/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "Folder.h"

@interface Folder (Private)

- (void)updateReadMessagesCount;

@end


@implementation Folder 

@dynamic folderId;
@dynamic name;

@dynamic messages;
@dynamic server;

@dynamic users;

@dynamic readMessagesCount;
@dynamic unreadMessagesCount;

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    [self updateReadMessagesCount];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(managedObjectContextChanged:) name:nil object:[self managedObjectContext]];
}

- (void)managedObjectContextChanged:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:NSManagedObjectContextObjectsDidChangeNotification])
    {
        [self updateReadMessagesCount];
    }
}

+ (NSSet *)keyPathsForValuesAffectingUsers
{
    return [NSSet setWithObject:@"messages"];
}

- (NSSet *)users
{
    return [self valueForKeyPath:@"messages.@distinctUnionOfObjects.user"];
}

- (void)updateReadMessagesCount
{
    NSUInteger readCount = [[self valueForKeyPath:@"messages.@sum.read"] intValue];
    NSUInteger allCount = [[self valueForKeyPath:@"messages.@count"] intValue];
    NSUInteger unreadCount = allCount - readCount;
    
    if (readCount != [mReadMessagesCount intValue])
    {
        [self willChangeValueForKey:@"readMessagesCount"];
        mReadMessagesCount = [NSNumber numberWithInt:readCount];
        [self didChangeValueForKey:@"readMessagesCount"];
    }
    
    if (unreadCount != [mUnreadMessagesCount intValue])
    {
        [self willChangeValueForKey:@"unreadMessagesCount"];
        mUnreadMessagesCount = [NSNumber numberWithInt:unreadCount];
        [self didChangeValueForKey:@"unreadMessagesCount"];
    }
}

- (NSNumber *)readMessagesCount
{
    return mReadMessagesCount;
}

- (NSNumber *)unreadMessagesCount
{
    return mUnreadMessagesCount;
}

@end



