//
//  MessageAttachmentTransformer.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 11/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "MessageAttachmentTransformer.h"
#import "MessageAttachment.h"

@interface MessageAttachmentsStringTransformer : MessageAttachmentTransformer { }
@end

@interface MessageAttachmentStringTransformer : MessageAttachmentTransformer { }
@end

@implementation MessageAttachmentTransformer

+ (id)messageAttachmentsString
{
    return [[MessageAttachmentsStringTransformer alloc] init];
}

+ (id)messageAttachmentString
{
    return [[MessageAttachmentStringTransformer alloc] init];
}

@end

@implementation MessageAttachmentsStringTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if ([value isKindOfClass:[NSArray class]])
    {
        NSArray *set = (NSArray *)value;
        
        if ([set count] > 0)
        {
            NSUInteger count = [set count];
            NSUInteger size = 0;
            for (MessageAttachment *att in set)
            {
                size += [att.data length];
            }
            
            NSString *attString = @"Attachment";
            
            if (count > 1)
            {
                attString = @"Attachments";
            }
            
            return [NSString stringWithFormat:@"%d %@, %d bytes", count, attString, size];
        }
    }
    
    return @"No Attachments";
}

@end

@implementation MessageAttachmentStringTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if ([value isKindOfClass:[MessageAttachment class]])
    {
        MessageAttachment *a = (MessageAttachment *)value;
        return [a fileName];
    }
    
    return nil;
}

@end
