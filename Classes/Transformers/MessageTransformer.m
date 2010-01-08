//
//  MessageTransformer.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 09/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "MessageTransformer.h"
#import "Message.h"
#import "EDMessage.h"

@implementation MessageTransformer

+ (Class)transformedValueClass
{
    return [NSObject class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)initForFontSize:(NSNumber *)fontSize
{
    if (self = [super init])
    {
        mFontSize = fontSize;
    }
    
    return self;
}

- (id)transformedValue:(id)value
{
    if ([value isKindOfClass:[Message class]])
    {
        if (mFontSize)
        {
            return mFontSize;
        }
    }
    
    return nil;
}

@end
