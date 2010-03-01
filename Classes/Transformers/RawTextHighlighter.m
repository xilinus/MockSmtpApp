//
//  RawTextHighlighter.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 01/03/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import "RawTextHighlighter.h"


@implementation RawTextHighlighter

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    if (![value isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    NSString *string = (NSString *)value;
    return [[NSAttributedString alloc] initWithString:string
                                           attributes:[NSDictionary dictionaryWithObject:[NSFont fontWithName:@"Monaco" size:12.0f]
                                                                                  forKey:NSFontAttributeName]];
}

- (id)reverseTransformedValue:(id)value
{
    if (![value isKindOfClass:[NSAttributedString class]])
    {
        return nil;
    }
    
    NSAttributedString *attrString = (NSAttributedString *)value;
    return [attrString string];
}

@end
