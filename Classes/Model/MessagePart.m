//
//  MessagePart.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 10/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "MessagePart.h"

@implementation MessagePart

@synthesize content = mContent;

+ (id)messagePartWithHtml:(NSString *)html
{
    return [[HtmlMessagePart alloc] initWithContent:html];
}

+ (id)messagePartWithText:(NSString *)text
{
    return [[TextMessagePart alloc] initWithContent:text];
}

- (id)initWithContent:(NSString *)content
{
    if (self = [super init])
    {
        mContent = content;
    }
    
    return self;
}

@end

@implementation HtmlMessagePart : MessagePart
@end

@implementation TextMessagePart : MessagePart
@end
