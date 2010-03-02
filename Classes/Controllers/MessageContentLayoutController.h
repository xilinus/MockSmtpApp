//
//  MessageContentLayoutController.h
//  MockSmtp
//
//  Created by Oleg Shnitko on 02/03/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MessageContentLayoutController : NSObjectController
{
@private
    
    NSView *mHeaderView;
    NSView *mSeparatorView;
    NSView *mContentView;
    
    NSView *mCcView;
    NSView *mCcLabel;
    
    NSView *mDateView;
    NSView *mDateLabel;
    
    NSView *mAttachmentsView;
}

@property (nonatomic, assign) IBOutlet NSView *headerView;
@property (nonatomic, assign) IBOutlet NSView *separatorView;
@property (nonatomic, assign) IBOutlet NSView *contentView;

@property (nonatomic, assign) IBOutlet NSView *ccView;
@property (nonatomic, assign) IBOutlet NSView *ccLabel;

@property (nonatomic, assign) IBOutlet NSView *dateView;
@property (nonatomic, assign) IBOutlet NSView *dateLabel;

@property (nonatomic, assign) IBOutlet NSView *attachmentsView;

@end
