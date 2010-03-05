//
//  LogController.h
//  MockSmtp
//
//  Created by Oleg Shnitko on 05/03/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LogController : NSObject
{
@private
    
    NSString *mLogString;
}

@property (nonatomic, retain) NSString *logString;

- (void)logComponent:(NSString *)component info:(NSString *)info;
- (void)logComponent:(NSString *)component error:(NSString *)error;

- (IBAction)clearLog:(id)sender;

@end
