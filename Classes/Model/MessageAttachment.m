//
//  MessageAttachment.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 10/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "MessageAttachment.h"


@implementation MessageAttachment

@synthesize data = mData;
@synthesize fileName = mFileName;

- (id)initWithData:(NSData *)data fileName:(NSString *)fileName
{
    if (self = [super init])
    {
        mData = data;
        mFileName = fileName;
    }
    
    return self;
}

@end
