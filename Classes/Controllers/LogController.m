//
//  LogController.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 05/03/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import "LogController.h"


@implementation LogController

@synthesize logString = mLogString;

- (void)awakeFromNib
{
    self.logString = @"";
}

- (void)appendLog:(NSString *)log
{
    self.logString = [NSString stringWithFormat:@"%@%@", self.logString, log];
}

- (void)appendTimedLog:(NSString *)log
{
    NSString *timedLog = [NSString stringWithFormat:@"%@ %@\n", [NSDate date], log];
    [self appendLog:timedLog];
}

- (void)appendLog:(NSString *)log level:(NSString *)level
{
    NSString *levelLog = [NSString stringWithFormat:@"%@ %@", level, log];
    [self appendTimedLog:levelLog];
}

- (void)logComponent:(NSString *)component info:(NSString *)info
{
    NSString *componentLog = [NSString stringWithFormat:@"[%@] %@", component, info];
    [self appendLog:componentLog level:@"I"];
}

- (void)logComponent:(NSString *)component error:(NSString *)error
{
    NSString *componentLog = [NSString stringWithFormat:@"[%@] %@", component, error];
    [self appendLog:componentLog level:@"E"];
}

- (IBAction)clearLog:(id)sender
{
    self.logString = @"";
}

@end
