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

@implementation DocumentController

@synthesize defaultsController = mDefaultsController;

- (void)awakeFromNib
{
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
    Document *doc = [self openDocumentWithContentsOfURL:fileUrl display:YES error:&error];
    
    if (error)
    {
        [self presentError:error];
        return;
    }
    
    [doc save];
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
        
        for (Document *document in [self documents])
        {
            [document save];
            [document close];
        }
        
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
        Document *doc = [self openDocumentWithContentsOfURL:fileUrl display:YES error:&error];
        
        if (error)
        {
            [self presentError:error];
            return;
        }
        
        [doc save];
    }
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
