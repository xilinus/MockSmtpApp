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
#import "MessagePartController.h"

@interface Document(Private)

@property (nonatomic, readonly) MessagePartController *messagePartController;

@end


@implementation Document

@synthesize server = _server;
@synthesize selectedView = mSelectedView;
@synthesize mainWindowController = mMainWindowController;

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

- (BOOL)isViewWithIndexHidden:(NSUInteger)index
{
    return mSelectedView != index;
}

- (BOOL)htmlViewHidden
{
    return [self isViewWithIndexHidden:0];
}

- (BOOL)bodyViewHidden
{
    return [self isViewWithIndexHidden:1];
}

- (BOOL)rawViewHidden
{
    return [self isViewWithIndexHidden:2];
}

- (void)setSelectedView:(NSUInteger)index
{
    if (mSelectedView == index)
    {
        return;
    }
    
    [self willChangeValueForKey:@"selectedView"];
    [self willChangeValueForKey:@"htmlViewHidden"];
    [self willChangeValueForKey:@"bodyViewHidden"];
    [self willChangeValueForKey:@"rawViewHidden"];
    mSelectedView = index;
    [self didChangeValueForKey:@"selectedView"];
    [self didChangeValueForKey:@"htmlViewHidden"];
    [self didChangeValueForKey:@"bodyViewHidden"];
    [self didChangeValueForKey:@"rawViewHidden"];
    
    NSLog(@"index change: %d", mSelectedView);
}

- (IBAction)delete:(id)sender
{
    [mMainWindowController delete:sender];
}

+ (NSSet *)keyPathsForValuesAffectingCanDelete
{
    return [NSSet setWithObjects:@"mainWindowController.canDelete", nil];
}

- (BOOL)canDelete
{
    return [[self.mainWindowController valueForKey:@"canDelete"] boolValue];
}

- (IBAction)restore:(id)sender
{
    [mMainWindowController restore:sender];
}

+ (NSSet *)keyPathsForValuesAffectingCanRestore
{
    return [NSSet setWithObjects:@"mainWindowController.canRestore", nil];
}

- (BOOL)canRestore
{
    return [[self.mainWindowController valueForKey:@"canRestore"] boolValue];
}

- (IBAction)showNextAlternative:(id)sender
{
    [self.messagePartController showNextAlternative:sender];
}

- (IBAction)showPrevAlternative:(id)sender
{
    [self.messagePartController showPrevAlternative:sender];
}

- (IBAction)showBestAlternative:(id)sender
{
    [self.messagePartController showBestAlternative:sender];
}

+ (NSSet *)keyPathsForValuesAffectingCanShowNextAlternative
{
    return [NSSet setWithObject:@"messagePartController.canShowNextAlternative"];
}

- (BOOL)canShowNextAlternative
{
    return self.messagePartController.canShowNextAlternative;
}

+ (NSSet *)keyPathsForValuesAffectingCanShowPrevAlternative
{
    return [NSSet setWithObject:@"messagePartController.canShowPrevAlternative"];
}

- (BOOL)canShowPrevAlternative
{
    return self.messagePartController.canShowPrevAlternative;
}

+ (NSSet *)keyPathsForValuesAffectingCanShowBestAlternative
{
    return [NSSet setWithObject:@"messagePartController.canShowBestAlternative"];
}

- (BOOL)canShowBestAlternative
{
    return self.messagePartController.canShowBestAlternative;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
    [super windowControllerDidLoadNib:windowController];
}

@end

@implementation Document(Private)

- (MessagePartController *)messagePartController
{
    return self.mainWindowController.messagePartController;
}

@end

