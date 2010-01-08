//
//  NSFileManager.h
//  MockSmtp
//
//  Created by Oleg Shnitko on 05/01/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSFileManager(SCExtensions)

- (BOOL)createDirectoryAtPathIfNotExists:(NSString *)path error:(NSError **)error;

+ (BOOL)createDirectoryAtPathIfNotExists:(NSString *)path error:(NSError **)error;

@end
