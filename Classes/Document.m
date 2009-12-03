//
//  MyDocument.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 11/11/2009.
//  Copyright Natural Devices, Inc. 2009 . All rights reserved.
//

#import "Document.h"
#import "MainWindowController.h"
#import "NewServerWindowController.h"

@implementation Document

@synthesize server = _server;

- (id)init 
{
    self = [super init];
    if (self != nil)
    {
    }
    
    return self;
}

- (id)initWithType:(NSString *)typeName error:(NSError **)outError
{
    self = [super initWithType:typeName error:outError];
    if (self != nil)
    {
    }
    
    return self;
}

- (NSManagedObject *)server
{
    if(_server != nil)
    {
        return _server;
    }
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSError *fetchError = nil;
    NSArray *fetchResults;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Server"
                                              inManagedObjectContext:moc];
    
    [fetchRequest setEntity:entity];
    fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
    
    if ((fetchResults != nil) && ([fetchResults count] == 1) && (fetchError == nil)) 
    {
        self.server = [fetchResults objectAtIndex:0];
        return _server;
    }
    
    self.server = [NSEntityDescription insertNewObjectForEntityForName:@"Server"
                                                inManagedObjectContext:moc];
    
    NSUndoManager *undoManager = [moc undoManager];
    
    [undoManager disableUndoRegistration];
    [moc processPendingChanges];
    [undoManager enableUndoRegistration];
    
    if (fetchError != nil)
    {
        [self presentError:fetchError];
    }
    
    return _server;
}

- (void)makeWindowControllers
{
    mMainWindowController = [[MainWindowController alloc] init];
    //mNewServerWindowController = [[NewServerWindowController alloc] init];
    
    //if (mIsNewFile)
   // {
    //    [self addWindowController:mNewServerWindowController];
    //}
    //else
    //{
        [self addWindowController:mMainWindowController];
    //}
}

- (void)create
{
    //[self removeWindowController:mNewServerWindowController];
    //[self addWindowController:mMainWindowController];
    //[mMainWindowController showWindow:self];
}

- (void)save
{
    [[self managedObjectContext] processPendingChanges];
    [super saveDocument:self];
}

- (void)cancel
{
    [self close];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
    [super windowControllerDidLoadNib:windowController];
    // user interface preparation code
}

@end
