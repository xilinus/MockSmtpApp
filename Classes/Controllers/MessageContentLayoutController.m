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

@synthesize attachmentsLabel = mAttachmentsLabel;
@synthesize attachmentsButton = mAttachmentsButton;
@synthesize attachmentsView = mAttachmentsView;

- (void)adjustFramesCC:(CGFloat)delta
{
    NSRect headerRect = [mHeaderView frame];
    NSRect separatorRect = [mSeparatorView frame];
    NSRect contentRect = [mContentView frame];
    
    NSRect dateViewRect = [mDateView frame];
    NSRect dateLabelRect = [mDateLabel frame];
	
	NSRect attachmentsLabelRect = [mAttachmentsLabel frame];
	NSRect attachmentsButtonRect = [mAttachmentsButton frame];
    NSRect attachmentsViewRect = [mAttachmentsView frame];
    
    dateViewRect.origin.y -= delta;
    dateLabelRect.origin.y -= delta;
	
	attachmentsLabelRect.origin.y -= delta;
	attachmentsButtonRect.origin.y -= delta;
    attachmentsViewRect.origin.y -= delta;
    
    headerRect.size.height += delta;
    headerRect.origin.y -= delta;
    separatorRect.origin.y -= delta;
    contentRect.size.height -= delta;
    
    [mDateView setFrame:dateViewRect];
    [mDateLabel setFrame:dateLabelRect];
	
	[mAttachmentsLabel setFrame:attachmentsLabelRect];
	[mAttachmentsButton setFrame:attachmentsButtonRect];
    [mAttachmentsView setFrame:attachmentsViewRect];
    
    [mHeaderView setFrame:headerRect];
    [mSeparatorView setFrame:separatorRect];
    [mContentView setFrame:contentRect];
}

- (void)adjustFramesAttachments:(CGFloat)delta
{
	NSRect headerRect = [mHeaderView frame];
    NSRect separatorRect = [mSeparatorView frame];
    NSRect contentRect = [mContentView frame];
    
	headerRect.size.height += delta;
    headerRect.origin.y -= delta;
    separatorRect.origin.y -= delta;
    contentRect.size.height -= delta;
	
	[mHeaderView setFrame:headerRect];
    [mSeparatorView setFrame:separatorRect];
    [mContentView setFrame:contentRect];
}

- (void)setCcHidden:(BOOL)hidden
{
    [mCcView setHidden:hidden];
    [mCcLabel setHidden:hidden];
}

- (void)setAttachmentsHidden:(BOOL)hidden
{
	[mAttachmentsLabel setHidden:hidden];
	[mAttachmentsButton setHidden:hidden];
	[mAttachmentsView setHidden:hidden];
	_hidden = hidden;
}

- (void)showCc
{
    NSRect ccRect = [mCcView frame];
    CGFloat delta = ccRect.size.height + 1;
    [self adjustFramesCC:delta];
    [self setCcHidden:NO];
}

- (void)showAttachments
{
	NSRect attachmentsViewRect = [mAttachmentsView frame];
    CGFloat delta = attachmentsViewRect.size.height + 15;
	[self adjustFramesAttachments:delta];
	[self setAttachmentsHidden:NO];
}

- (void)hideCc
{
    NSRect ccRect = [mCcView frame];
    CGFloat delta = ccRect.size.height + 1;
    [self adjustFramesCC:-delta];
    [self setCcHidden:YES];
}

- (void)hideAttachments
{
	NSRect attachmentsViewRect = [mAttachmentsView frame];
    CGFloat delta = attachmentsViewRect.size.height + 15;
	[self adjustFramesAttachments:-delta];
	[self setAttachmentsHidden:YES];
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
	
	if (message.attachments)
    {
        if (_hidden)
        {
            [self showAttachments];
        }
    }
    else
    {
        if (!_hidden)
        {
            [self hideAttachments];
        }
    }
}

@end
