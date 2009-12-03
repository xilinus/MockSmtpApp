//
//  NewServerWindowController.h
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 26/11/2009.
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NewServerWindowController : NSWindowController
{
@private
    NSTextField *mName;
    NSTextField *mAddress;
    NSTextField *mPort;
}

- (id)init;

- (IBAction)create:(id)sender;
- (IBAction)cancel:(id)sender;

@property (nonatomic, assign) IBOutlet NSTextField *name;
@property (nonatomic, assign) IBOutlet NSTextField *address;
@property (nonatomic, assign) IBOutlet NSTextField *port;

@end
