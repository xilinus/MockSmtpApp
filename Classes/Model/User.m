// 
//  User.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 12/11/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "User.h"
#import "Folder.h"

@implementation User 

@dynamic address;

@dynamic messages;
@dynamic server;

- (NSSet *)messagesInFolder:(Folder *)folder
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ and folder == %@", self, folder];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    
    if ((results != nil) && (error == nil)) 
    {
        return [NSSet setWithArray:results];
    }
    
    return nil;
}

@end
