//
//  ApplicationDelegate.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 26/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import "DocumentController.h"
#import "Document.h"

#import "MessageTransformer.h"
#import "MessagePartTransformer.h"
#import "MessageAttachmentTransformer.h"

@implementation DocumentController

@synthesize defaultsController = mDefaultsController;
@synthesize document = mDocument;

+ (void)initialize
{
    MessageTransformer *messageFontSize = [[MessageTransformer alloc] initForFontSize:[NSNumber numberWithInt:11]];
    [NSValueTransformer setValueTransformer:messageFontSize forName:@"MessageFontSize"];
    
    MessagePartTransformer *messagePartIsHtml = [MessagePartTransformer messagePartIsHtml];
    [NSValueTransformer setValueTransformer:messagePartIsHtml forName:@"MessagePartIsHtml"];
    
    MessageAttachmentTransformer *messageAttachmentsString = [MessageAttachmentTransformer messageAttachmentsString];
    [NSValueTransformer setValueTransformer:messageAttachmentsString forName:@"MessageAttachmentsString"];
    
    MessageAttachmentTransformer *messageAttachmentString = [MessageAttachmentTransformer messageAttachmentString];
    [NSValueTransformer setValueTransformer:messageAttachmentString forName:@"MessageAttachmentString"];
}

- (void)awakeFromNib
{
    [mDefaultsController setInitialValues:[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"default.data", @"fileName",
                                           @"~/Documents/MockSMTP", @"location",
                                           [NSNumber numberWithInt:1025], @"port",
                                           [NSNumber numberWithBool:NO], @"autoUpdate", nil]];
    
    mFileName = [[mDefaultsController values] valueForKey:@"fileName"];
    mLocation = [[mDefaultsController values] valueForKey:@"location"];
    
    [mDefaultsController setAppliesImmediately:NO];
    [mDefaultsController addObserver:self forKeyPath:@"values.fileName" options:NSKeyValueObservingOptionNew context:nil];
    [mDefaultsController addObserver:self forKeyPath:@"values.location" options:NSKeyValueObservingOptionNew context:nil];
    
    NSString *folder =  [mLocation stringByStandardizingPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:folder] == NO)
    {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error)
        {
            [self presentError:error];
            return;
        }
    }
    
    NSString *path = [mLocation stringByAppendingPathComponent:mFileName];
    path = [path stringByStandardizingPath];
    
    NSURL *fileUrl = [NSURL fileURLWithPath:path];
    
    NSError *error = nil;
    self.document = [self openDocumentWithContentsOfURL:fileUrl display:YES error:&error];
    
    if (error)
    {
        [self presentError:error];
        return;
    }
    
    [self.document save];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *name = [[mDefaultsController values] valueForKey:@"fileName"];
    NSString *location = [[mDefaultsController values] valueForKey:@"location"];
    NSString *savedName = [[mDefaultsController defaults] stringForKey:@"fileName"];
    NSString *savedLocation = [[mDefaultsController defaults] stringForKey:@"location"];
    
    if ([savedName isEqualToString:name] && [savedLocation isEqualToString:location]
        && (![mFileName isEqualToString:savedName] || ![mLocation isEqualToString:savedLocation]))
    {
        
        NSArray *docs = [[self documents] copy];
        
        mFileName = name;
        mLocation = location;
        
        NSString *folder =  [mLocation stringByStandardizingPath];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:folder] == NO)
        {
            NSError *error = nil;
            [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
            
            if (error)
            {
                [self presentError:error];
                return;
            }
        }
        
        NSString *path = [mLocation stringByAppendingPathComponent:mFileName];
        path = [path stringByStandardizingPath];
        
        NSURL *fileUrl = [NSURL fileURLWithPath:path];
        
        NSError *error = nil;
        self.document = [self openDocumentWithContentsOfURL:fileUrl display:YES error:&error];
        
        if (error)
        {
            [self presentError:error];
            return;
        }
        
        [self.document save];
        
        for (Document *document in docs)
        {
            [document save];
            [document close];
        }
        
    }
}

- (void)showViewWithIndex:(NSUInteger)index
{
    [self.document setValue:[NSNumber numberWithInt:index] forKey:@"selectedView"];
}

- (IBAction)showHtml:(id)sender
{
    [self showViewWithIndex:0];
}

- (IBAction)showBody:(id)sender
{
    [self showViewWithIndex:1];
}

- (IBAction)showRaw:(id)sender
{
    [self showViewWithIndex:2];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return NO;
}

- (IBAction)newDocument:(id)sender
{
    [super newDocument:sender];
}

@end
