//
//  MessageAttachment.h
//  MockSmtp
//
//  Created by Oleg Shnitko on 10/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MessageAttachment : NSObject
{
@private
    
    NSData *mData;
    NSString *mFileName;
}

- (id)initWithData:(NSData *)data fileName:(NSString *)fileName;

@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSString *fileName;

@end
