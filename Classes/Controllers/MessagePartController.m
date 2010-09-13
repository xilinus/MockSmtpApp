//
//  MessagePartController.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 02/03/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import "MessagePartController.h"
#import "Message.h"

@interface MessagePartController(Private)

- (void)setCurrentPartIndex:(NSUInteger)index;

@end


@implementation MessagePartController

- (void)setContent:(id)content
{
    [super setContent:content];
    
    Message *message = (Message *)content;
    NSArray *parts = [message subparts];
    MessagePart *bestPart = [message bestPart];
    mPartsCount = [parts count];
	mBestPartIndex = NSNotFound;
	if (bestPart)
	{
		mBestPartIndex = [parts indexOfObject:bestPart];
    }
	
	[self setCurrentPartIndex:mBestPartIndex];
}

- (IBAction)showNextAlternative:(id)sender
{
    [self setCurrentPartIndex:(mCurrentPartIndex + 1)];
}

- (IBAction)showPrevAlternative:(id)sender
{
    [self setCurrentPartIndex:(mCurrentPartIndex - 1)];
}

- (IBAction)showBestAlternative:(id)sender
{
    [self setCurrentPartIndex:mBestPartIndex];
}

- (BOOL)canShowNextAlternative
{
    return mCurrentPartIndex < (mPartsCount - 1);
}

- (BOOL)canShowPrevAlternative
{
    return mCurrentPartIndex > 0;
}

- (BOOL)canShowBestAlternative
{
    return mCurrentPartIndex != mBestPartIndex;
}

- (void)setCurrentPartIndex:(NSUInteger)index
{
    [self willChangeValueForKey:@"currentPart"];
    [self willChangeValueForKey:@"canShowNextAlternative"];
    [self willChangeValueForKey:@"canShowPrevAlternative"];
    [self willChangeValueForKey:@"canShowBestAlternative"];
    mCurrentPartIndex = index;
    [self didChangeValueForKey:@"currentPart"];
    [self didChangeValueForKey:@"canShowNextAlternative"];
    [self didChangeValueForKey:@"canShowPrevAlternative"];
    [self didChangeValueForKey:@"canShowBestAlternative"];
    
}

- (MessagePart *)currentPart
{
	if (mCurrentPartIndex == NSNotFound)
	{
		return nil;
	}
	
    Message *message = (Message *)self.content;
    NSArray *parts = [message subparts];
    MessagePart *part = [parts objectAtIndex:mCurrentPartIndex];
    
    return part;
}

@end
