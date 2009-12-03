//
//  SegmentController.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 24/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SegmentController : NSObject
{

@private
    NSSegmentedControl *mSegControll;
    NSTabView *mTabView;
}

- (IBAction)segControllClicked:(id)sender;

@property (nonatomic, assign) IBOutlet NSSegmentedControl *segControll;
@property (nonatomic, assign) IBOutlet NSTabView *tabView;

@end
