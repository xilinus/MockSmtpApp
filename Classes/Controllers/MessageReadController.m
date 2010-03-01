//
//  MessageReadController.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 01/03/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import "MessageReadController.h"
#import "Message.h"

@implementation MessageReadController

- (void)setContent:(id)content
{
    [super setContent:content];
    
    Message *msg = (Message *)content;
    [msg setRead:[NSNumber numberWithBool:YES]];
    [[self managedObjectContext] processPendingChanges];    
}


@end
