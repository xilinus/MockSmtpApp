//
//  MessagePart.h
//  MockSmtp
//
//  Created by Oleg Shnitko on 10/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MessagePart : NSObject
{
@private
    
    NSString *mContent;
}

+ (id)messagePartWithHtml:(NSString *)html;
+ (id)messagePartWithText:(NSString *)text;

- (id)initWithContent:(NSString *)content;

@property (nonatomic, readonly) NSString *content;

@end

@interface HtmlMessagePart : MessagePart
@end

@interface TextMessagePart : MessagePart
@end

