//
//  AttachmentsController.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 11/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "AttachmentsController.h"
#import "MessageAttachment.h"

@implementation AttachmentsController

@synthesize window = mWindow;

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSOKButton)
    {
        MessageAttachment *att = (MessageAttachment *)contextInfo;
        [att.data writeToURL:[sheet URL] atomically:YES];
    }
}

- (void)saveAtIndex:(NSInteger)index inDirectory:(NSString *)directory
{
    MessageAttachment *att = [[self arrangedObjects] objectAtIndex:index];
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel beginSheetForDirectory:directory
                                 file:[att fileName]
                       modalForWindow:[self window]
                        modalDelegate:self
                       didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)
                          contextInfo:att];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
    if (returnCode == NSOKButton)
    {
        //NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *dir = [panel directory];
        
        for (NSUInteger i = 0; i < [[self arrangedObjects] count]; i++)
        {
            MessageAttachment *att = [[self arrangedObjects] objectAtIndex:i];
            NSString *file = [dir stringByAppendingPathComponent:[att fileName]];
            
            //if ([fileManager fileExistsAtPath:file])
            //{
            //    [self saveAtIndex:i inDirectory:dir];
            //}
            //else
            //{
                [att.data writeToFile:file atomically:YES];
            //}
        }
    }
}

- (void)saveAll
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel beginSheetForDirectory:nil
                                 file:nil
                       modalForWindow:[self window]
                        modalDelegate:self
                       didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
                          contextInfo:self];
}

- (IBAction)saveAttachment:(id)sender
{
    NSPopUpButton *btn = (NSPopUpButton *)sender;
    
    NSInteger index = [btn indexOfSelectedItem];
    
    if (index == 1)
    {
        [self saveAll];
    }
    else
    {
        [self saveAtIndex:(index - 3) inDirectory:nil];
    }
}

@end
