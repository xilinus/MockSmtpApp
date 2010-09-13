//
//  BadgeController.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 24/02/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import "BadgeController.h"

@implementation BadgeController

- (void)setContent:(id)content
{
    [super setContent:content];
    
    NSInteger count = [content intValue];
    NSDockTile *tile = [[NSApplication sharedApplication] dockTile];
    if (count > 0)
    {
        [tile setBadgeLabel:[NSString stringWithFormat:@"%d", count]];
    }
    else
    {
        [tile setBadgeLabel:nil];
    }
}


@end
