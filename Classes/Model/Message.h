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
@class MessagePart;

@class EDInternetMessage;

@interface Message :  NSManagedObject  
{
@private
    EDInternetMessage *mEdMessage;
    
    NSString *mFrom;
    NSString *mTo;
    NSString *mSubject;
    NSCalendarDate *mDate;
    NSString *mCC;
    
    BOOL mHeaderParsed;
    
    NSMutableSet *mSubparts;
    MessagePart *mBestPart;
    
    NSMutableArray *mAttachments;
    
    BOOL mContentParsed;
    
    NSString *mTransferText;
}

@property (nonatomic, retain) NSNumber *read;
@property (nonatomic, retain) NSData *transferData;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Folder *folder;

@property (nonatomic, readonly) EDInternetMessage *edMessage;

@property (nonatomic, readonly) NSString *from;
@property (nonatomic, readonly) NSString *to;
@property (nonatomic, readonly) NSString *subject;
@property (nonatomic, readonly) NSCalendarDate *date;
@property (nonatomic, readonly) NSString *cc;

@property (nonatomic, readonly) NSSet *subparts;
@property (nonatomic, readonly) MessagePart *bestPart;

@property (nonatomic, readonly) NSArray *attachments;

@property (nonatomic, readonly) NSString *transferText;

@end

