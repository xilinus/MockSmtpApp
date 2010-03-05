//
//  SmtpClient.h
//  MockSmtp
//
//  Created by Oleg Shnitko on 04/03/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LogController.h"

@interface SmtpClient : NSObject
{
@private
    
    NSMutableArray *mQueue;
    
    BOOL mDelivering;
    
    NSUInteger mTaskCount;
    NSUInteger mProcessingCount;
    NSUInteger mWaintingCount;
    NSUInteger mSendingCount;
    NSUInteger mSentCount;
    NSUInteger mFailCount;
    
    NSAttributedString *mStatus;
    
    LogController *mLogController;
}

- (void)deliverMessages:(NSArray *)messages;

@property (assign) NSUInteger taskCount;
@property (assign) NSUInteger processingCount;
@property (assign) NSUInteger waitingCount;
@property (assign) NSUInteger sendingCount;
@property (assign) NSUInteger sentCount;
@property (assign) NSUInteger failCount;

@property (assign) BOOL delivering;

@property (retain) NSAttributedString *status;

@property (nonatomic, assign) IBOutlet LogController *logController;

@end
