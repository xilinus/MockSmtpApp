// 
//  ServerFolder.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 11/11/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "Folder.h"

@interface Folder (Private)

- (void)updateUsers;
- (void)updateReadMessagesCount;

@end


@implementation Folder 

@synthesize users = mUsers;
@synthesize usersFolders = mUsersFolders;

@dynamic folderId;
@dynamic name;

@dynamic messages;
@dynamic server;

@dynamic readMessagesCount;
@dynamic unreadMessagesCount;

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    [self updateReadMessagesCount];
    [self updateUsers];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(managedObjectContextChanged:) name:nil object:[self managedObjectContext]];
}

- (void)managedObjectContextChanged:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:NSManagedObjectContextObjectsDidChangeNotification])
    {
        [self updateReadMessagesCount];
        [self updateUsers];
    }
}

- (void)updateUsers
{
    if (!mUsers)
    {
        mUsers = [[NSMutableSet alloc] init];
        mUsersFolders = [[NSMutableSet alloc] init];
    }
    
    NSSet *users = [self valueForKeyPath:@"messages.@distinctUnionOfObjects.user"];
    
    if ([users count] == 0)
    {
        [mUsers removeAllObjects];
        [mUsersFolders removeAllObjects];
    }
    
    [mUsers unionSet:users];
    [mUsers intersectSet:users];
    
    NSMutableSet *proxys = [[NSMutableSet alloc] initWithCapacity:[users count]];
    for (User *user in users)
    {
        UserProxy *proxy = [[UserProxy alloc] initWithUser:user folder:self];
        [proxys addObject:proxy];
    }
    [mUsersFolders unionSet:proxys];
    [mUsersFolders intersectSet:proxys];
}

- (NSMutableSet *)usersFolders
{
    [self updateUsers];
    return mUsersFolders;
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

@implementation UserProxy

@synthesize user = mUser;
@synthesize folder = mFolder;

- (id)initWithUser:(User *)user folder:(Folder *)folder
{
    if (self = [super init])
    {
        mUser = user;
        mFolder = folder;
    }
    
    return self;
}

- (NSUInteger)hash
{
    return [mUser hash];
}

- (BOOL)isEqual:(id)anObject
{
    UserProxy *p = (UserProxy *)anObject;
    return [mUser isEqual:p.user];
}

@end


