//
//  MessagePartTransformer.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 10/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "MessagePartTransformer.h"
#import "MessagePart.h"

@interface MessagePartIsHtmlTransformer : MessagePartTransformer { }
@end

@interface MessagePartIsTextTransformer : MessagePartTransformer { }
@end

@implementation MessagePartTransformer

+ (id)messagePartIsHtml
{
    return [[MessagePartIsHtmlTransformer alloc] init];
}

+ (id)messagePartIsText
{
    return [[MessagePartIsTextTransformer alloc] init];
}

@end

@implementation MessagePartIsHtmlTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if ([value isKindOfClass:[HtmlMessagePart class]])
    {
        return [NSNumber numberWithBool:YES];
    }
    
    return [NSNumber numberWithBool:NO];
}

@end

@implementation MessagePartIsTextTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if ([value isKindOfClass:[TextMessagePart class]])
    {
        return [NSNumber numberWithBool:YES];
    }
    
    return [NSNumber numberWithBool:NO];
}

@end
