//
//  MessageAttachment.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 10/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "MessageAttachment.h"


@implementation MessageAttachment

@synthesize data = mData;
@synthesize fileName = mFileName;

- (id)initWithData:(NSData *)data fileName:(NSString *)fileName
{
    if (self = [super init])
    {
        mData = data;
        mFileName = fileName;
    }
    
    return self;
}

- (NSImage *)icon
{
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSString *extension = @"";
	NSArray *components = [self.fileName componentsSeparatedByString:@"."];
	if (components.count > 1)
	{
		extension = [components lastObject];
	}
	
	return [ws iconForFileType:extension];
}

- (void)open
{
	NSLog(@"open attachment: %@", self);
	
	NSString *folder =  [@"~/Documents/MockSMTP/Downloads" stringByStandardizingPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:folder] == NO)
    {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error)
        {
            return;
        }
    }
    
    NSString *path = [folder stringByAppendingPathComponent:self.fileName];
    path = [path stringByStandardizingPath];
	
	if ([fileManager fileExistsAtPath:path])
	{
		NSString *fileName = [self.fileName stringByDeletingPathExtension];
		NSString *extension = [self.fileName pathExtension];
		
		NSUInteger index = 1;
		
		NSString *newName = [NSString stringWithFormat:@"%@-%d.%@", fileName, index, extension];
		path = [folder stringByAppendingPathComponent:newName];
		path = [path stringByStandardizingPath];
		
		while ([fileManager fileExistsAtPath:path])
		{
			index++;
			newName = [NSString stringWithFormat:@"%@-%d.%@", fileName, index, extension];
			path = [folder stringByAppendingPathComponent:newName];
			path = [path stringByStandardizingPath];
		}
	}
	
	NSLog(@"path: %@", path);
	[self.data writeToFile:path atomically:YES];
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	[ws openFile:path];
}

- (void)save
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel beginSheetForDirectory:nil
                                 file:[self fileName]
                       modalForWindow:[NSApp mainWindow]
                        modalDelegate:self
                       didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)
                          contextInfo:nil];
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSOKButton)
    {
        [self.data writeToURL:[sheet URL] atomically:YES];
    }
}

@end
