// 
//  ServerFolder.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 11/11/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "Folder.h"


@implementation Folder 

@dynamic folderId;
@dynamic name;

@dynamic messages;
@dynamic server;

@dynamic users;

+ (NSSet *)keyPathsForValuesAffectingUsers
{
    return [NSSet setWithObject:@"messages"];
}

- (NSSet *)users
{
    return [self valueForKeyPath:@"messages.@distinctUnionOfObjects.user"];
}

@end



