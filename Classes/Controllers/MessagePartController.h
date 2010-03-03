//
//  MessagePartController.h
//  MockSmtp
//
//  Created by Oleg Shnitko on 02/03/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MessagePart.h"

@interface MessagePartController : NSObjectController
{
@private
    
    NSUInteger mCurrentPartIndex;
    NSUInteger mBestPartIndex;
    NSUInteger mPartsCount;
}

- (IBAction)showNextAlternative:(id)sender;
- (IBAction)showPrevAlternative:(id)sender;
- (IBAction)showBestAlternative:(id)sender;

@property (nonatomic, readonly) BOOL canShowNextAlternative;
@property (nonatomic, readonly) BOOL canShowPrevAlternative;
@property (nonatomic, readonly) BOOL canShowBestAlternative;

@property (nonatomic, readonly) MessagePart *currentPart;

@end
