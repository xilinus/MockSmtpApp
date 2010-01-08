//
//  MessagePartTransformer.h
//  MockSmtp
//
//  Created by Oleg Shnitko on 10/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MessagePartTransformer : NSValueTransformer
{
}

+ (id)messagePartIsHtml;
+ (id)messagePartIsText;

@end
