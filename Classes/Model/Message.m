// 
//  Message.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 18/11/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "Message.h"

#import "User.h"
#import "Folder.h"

@implementation Message 

@dynamic read;
@dynamic dateSent;
@dynamic receiver;
@dynamic subject;
@dynamic body;
@dynamic rawData;
@dynamic user;
@dynamic folder;

@dynamic sender;

- (void)awakeFromInsert
{
    self.dateSent = [[NSDate alloc] init];
}

+ (NSSet *)keyPathsForValuesAffectingSender
{
    return [NSSet setWithObject:@"user.address"];
}

- (NSString *)sender
{
    return [self.user address];
}

@end
