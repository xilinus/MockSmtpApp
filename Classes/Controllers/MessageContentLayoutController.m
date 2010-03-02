//
//  MessageContentLayoutController.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 02/03/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import "MessageContentLayoutController.h"
#import "Message.h"

@implementation MessageContentLayoutController

@synthesize headerView = mHeaderView;
@synthesize separatorView = mSeparatorView;
@synthesize contentView = mContentView;

@synthesize ccView = mCcView;
@synthesize ccLabel = mCcLabel;

@synthesize dateView = mDateView;
@synthesize dateLabel = mDateLabel;

@synthesize attachmentsView = mAttachmentsView;

- (void)adjustFrames:(CGFloat)delta
{
    NSRect headerRect = [mHeaderView frame];
    NSRect separatorRect = [mSeparatorView frame];
    NSRect contentRect = [mContentView frame];
    
    NSRect dateViewRect = [mDateView frame];
    NSRect dateLabelRect = [mDateLabel frame];
    NSRect attachmentsViewRect = [mAttachmentsView frame];
    
    dateViewRect.origin.y -= delta;
    dateLabelRect.origin.y -= delta;
    attachmentsViewRect.origin.y -= delta;
    
    headerRect.size.height += delta;
    headerRect.origin.y -= delta;
    separatorRect.origin.y -= delta;
    contentRect.size.height -= delta;
    
    [mDateView setFrame:dateViewRect];
    [mDateLabel setFrame:dateLabelRect];
    [mAttachmentsView setFrame:attachmentsViewRect];
    
    [mHeaderView setFrame:headerRect];
    [mSeparatorView setFrame:separatorRect];
    [mContentView setFrame:contentRect];
}

- (void)setCcHidden:(BOOL)hidden
{
    [mCcView setHidden:hidden];
    [mCcLabel setHidden:hidden];
}

- (void)showCc
{
    NSRect ccRect = [mCcView frame];
    CGFloat delta = ccRect.size.height + 1;
    [self adjustFrames:delta];
    [self setCcHidden:NO];
}

- (void)hideCc
{
    NSRect ccRect = [mCcView frame];
    CGFloat delta = ccRect.size.height + 1;
    [self adjustFrames:-delta];
    [self setCcHidden:YES];
}

- (void)setContent:(id)content
{
    [super setContent:content];
    
    Message *message = (Message *)content;
    
    NSString *cc = [message cc];
    if (cc)
    {
        if ([mCcView isHidden])
        {
            [self showCc];
        }
    }
    else
    {
        if (![mCcView isHidden])
        {
            [self hideCc];
        }
    }
}

@end
