//
//  MessageTransformer.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 09/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MessageTransformer : NSValueTransformer
{
@private    
    NSNumber *mFontSize;
}

- (id)initForFontSize:(NSNumber *)fontSize;

@end
