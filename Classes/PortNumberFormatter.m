//
//  PortNumberFormatter.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 06/01/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import "PortNumberFormatter.h"

@implementation PortNumberFormatter

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString  **)error
{
    
    BOOL returnValue = [super getObjectValue:obj forString:string errorDescription:error];
    
    if (error)
    {
        if (*error)
            *error = @"Port number must be in range 1 - 65535";
    }
    
    return returnValue;
}

@end
