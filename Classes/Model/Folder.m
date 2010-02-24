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
    //if ([[notification name] isEqualToString:NSManagedObjectContextObjectsDidChangeNotification])
    //{
        [self performSelectorOnMainThread:@selector(updateReadMessagesCount) withObject:nil waitUntilDone:NO];
    //}
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
    NSNumber *newCount = [self valueForKeyPath:@"messages.@sum.read"];
    NSNumber *allMessagesCount = [self valueForKeyPath:@"messages.@count"];
    
    [self willChangeValueForKey:@"readMessagesCount"];
    [self willChangeValueForKey:@"unreadMessagesCount"];
    mReadMessagesCount = newCount;
    mUnreadMessagesCount = [NSNumber numberWithInt:([allMessagesCount intValue] - [mReadMessagesCount intValue])];
    [self didChangeValueForKey:@"readMessagesCount"];
    [self didChangeValueForKey:@"unreadMessagesCount"];
    
    NSLog(@"count updated: %@", mReadMessagesCount);
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



