//
//  NSFileManager.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 05/01/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import "NSFileManager+Extensions.h"

@implementation NSFileManager(SCExtensions)

- (BOOL)createDirectoryAtPathIfNotExists:(NSString *)path error:(NSError **)error
{
    path = [path stringByStandardizingPath];
    if ([self fileExistsAtPath:path])
    {
        return YES;
    }
    
    return [self createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
}

+ (BOOL)createDirectoryAtPathIfNotExists:(NSString *)path error:(NSError **)error
{
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager createDirectoryAtPathIfNotExists:path error:error];
}

@end
