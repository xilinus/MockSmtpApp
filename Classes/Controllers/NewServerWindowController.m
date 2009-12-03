//
//  NewServerWindowController.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 26/11/2009.
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import "NewServerWindowController.h"
#import "Server.h"
#import "Document.h"

@implementation NewServerWindowController

@synthesize name = mName;
@synthesize address = mAddress;
@synthesize port = mPort;

- (id)init
{
    if (self = [super initWithWindowNibName:@"NewServerWindow"])
    {
    }
    
    return self;
}

- (IBAction)create:(id)sender
{
    Server *server = [[self document] valueForKey:@"server"];
    [server setName:[mName stringValue]];
    [server setPort:[NSNumber numberWithInt:[mPort intValue]]];
    [[[self document] managedObjectContext] processPendingChanges];
    
    [[self document] saveDocumentWithDelegate:self didSaveSelector:@selector(document:didSave:contextInfo:) contextInfo:nil];
}

- (void)document:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo
{
    if (didSave)
    {
        Document *d = [self document];
        [d create];
        [self close];
    }
}

- (IBAction)cancel:(id)sender
{
    Document *d = [self document];
    [d cancel];
    [self close];
}

@end
