//
//  MessageAttachmentTransformer.h
//  MockSmtp
//
//  Created by Oleg Shnitko on 11/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MessageAttachmentTransformer : NSValueTransformer
{
}

+ (id)messageAttachmentsString;
+ (id)messageAttachmentString;

@end
