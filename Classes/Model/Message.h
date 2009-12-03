//
//  Message.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 18/11/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import <CoreData/CoreData.h>

@class User;
@class Folder;

@interface Message :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSDate * dateSent;
@property (nonatomic, retain) NSString * receiver;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * rawData;
@property (nonatomic, retain) User * user;
@property (nonatomic, retain) Folder * folder;

@property (readonly) NSString *sender;

@end



