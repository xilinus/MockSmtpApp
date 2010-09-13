//
//  BodyTextHighlighter.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 01/03/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import "BodyTextHighlighter.h"


@implementation BodyTextHighlighter

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
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *templatePath = [mainBundle pathForResource:@"syntax" ofType:@"html"];
    NSString *templateString = [NSString stringWithContentsOfFile:templatePath encoding:NSASCIIStringEncoding error:nil];
    
    NSString *string = (NSString *)value;
    return [NSString stringWithFormat:templateString, string];    
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
