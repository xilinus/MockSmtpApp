//
//  MyDocument.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 11/11/2009.
//  Copyright Natural Devices, Inc. 2009 . All rights reserved.
//

#import "Document.h"
#import "MainWindowController.h"
#import "TrialWindowController.h"

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
    //NSDate *date = [[NSDate alloc] init];
    //NSCalendar *cal = [NSCalendar currentCalendar];
    
    //NSDateComponents *comp = [cal components:NSYearCalendarUnit fromDate:date];
    //if ([comp year] > 2009)
    
    NSDockTile *tile = [[NSApplication sharedApplication] dockTile];
    [tile setBadgeLabel:@"Lots"];
    
    if (![TrialWindowController checkLicense])
    {
        [TrialWindowController installDefaultLicenseFile];
    }
    
    if (![TrialWindowController checkLicense])
    {
        TrialWindowController *twc = [[TrialWindowController alloc] init];
        [self addWindowController:twc];
    }
    else
    {
        mMainWindowController = [[MainWindowController alloc] init];
        [self addWindowController:mMainWindowController];
    }
}

- (BOOL)isDocumentEdited
{
    return NO;
}

- (void)save
{
    [[self managedObjectContext] processPendingChanges];
    [super saveDocument:self];
}

- (void)close
{
    [super close];
    
    NSDocumentController *dc = [NSDocumentController sharedDocumentController];
    
    NSArray *docs = [dc documents];
    if ([docs count] == 0)
    {
        [[NSApplication sharedApplication] terminate:self];
    }
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
    [super windowControllerDidLoadNib:windowController];
    // user interface preparation code
}

@end
