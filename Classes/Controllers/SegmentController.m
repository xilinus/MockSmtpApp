//
//  SegmentController.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 24/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import "SegmentController.h"

@implementation SegmentController

@synthesize segControll = mSegControll;
@synthesize tabView = mTabView;

- (IBAction)segControllClicked:(id)sender
{
    [mTabView selectTabViewItemAtIndex:[mSegControll selectedSegment]];
}

@end
