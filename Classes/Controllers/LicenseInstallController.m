//
//  LicenseInstallController.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 15/01/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import "LicenseInstallController.h"
#import "LicenseController.h"
#import "NSFileManager+Extensions.h"

#define LICENSE_DIR @"~/.mocksmtp"
#define LICENSE_TMP_DIR @"~/.mocksmtp/tmp"
#define LICENSE_FILE @"license.plist"
#define LICENSE_SIG @"license.plist.sha1"
#define LICENSE_KEY_FILE @"public.pem"

#define PUB_KEY @"-----BEGIN PUBLIC KEY-----\n\
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA0iAwEdY94x/HAicCRc+3\n\
ghCwKesASUmZRciQNBgFZJ772ul9cyIsgJ7d9Xq7LR9fC3ym5cud+F/VzDT8/mec\n\
VesY+G8fIFwaWBJG9SUUxjhOfA+waybad1xbyfTULyIk9xoSo22tVx7SuYgYBhlh\n\
dyN/N6ijGNzuvtqsTnkRvv5gvzwCZvYdPvzkXlF/OTV2FRgWTZwcZDb26YJZ6mAd\n\
IoPu0h75qkkZit3fJ/tLxlwjAd7w0IZMpgIjGlUocN46RiVjR1xOqXrB6aQRlKAg\n\
FTOM1rosW2M04QfvLZrWrk0ojgRITg3BJNxTENBJzWSIcHaFV84BdrM55Ibh5Rlb\n\
clNGzWsulgW1IPs6lmszVciBHFW9yomzNKGYQWuvWKkqwowp7GXqgcdgdd52Q7Xp\n\
ssXzCgVTgz0gKCKn86IfebXikYREEm0VMf3rQ5Bab+//NnlZMXsNJKEOWL0ysYKX\n\
okqxwGWBdYs4GgVXYXjvi7DTDS5OlK0IgXe8AofXhRnPzE5HVOe1wYrSxYUw7o4T\n\
OeWZ60rWlsAEy/Uh6CH9b16mTKUaoV7l42krRLSUUBzq1seOAdm95tLYnqHW7ZGR\n\
fgLUcQU8RKsVl3s85HVxC7LLX1VCFhF1IIsQqdmX0pj+x5VFklTmIXsHatlUKJl5\n\
Vo1X9ZXjv3igiFT94vpwqKMCAwEAAQ==\n\
-----END PUBLIC KEY-----\n"

@implementation LicenseInstallController

@synthesize filePath = mFilePath;
@synthesize fileInfo = mFileInfo;
@synthesize product = mProduct;
@synthesize licenseType = mLicenseType;
@synthesize expire = mExpireText;
@synthesize registered = mRegistered;
@synthesize email = mEmail;

@synthesize activateButton = mActivateBtn;
@synthesize panel = mPanel;
@synthesize licenseController = mLicenseController;

+ (BOOL)checkLicenseFileExists
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
	lcl_log(lcl_cLicenseController, lcl_vTrace, @"Checking if license file exists...");
	
    NSString *licensePath = [[LICENSE_DIR stringByAppendingPathComponent:LICENSE_FILE] stringByStandardizingPath];
    if (![manager fileExistsAtPath:licensePath])
    {
		lcl_log(lcl_cLicenseController, lcl_vTrace, @"No license file exists at path %@", licensePath);
		lcl_log(lcl_cLicenseController, lcl_vTrace, @"Failed");
        return NO;
    }
    
    NSString *sigPath = [[LICENSE_DIR stringByAppendingPathComponent:LICENSE_SIG] stringByStandardizingPath];
    if (![manager fileExistsAtPath:sigPath])
    {
		lcl_log(lcl_cLicenseController, lcl_vTrace, @"No signature file exists at path %@", sigPath);
		lcl_log(lcl_cLicenseController, lcl_vTrace, @"Failed");
        return NO;
    }
    
	lcl_log(lcl_cLicenseController, lcl_vTrace, @"Ok");
    return YES;
}

+ (BOOL)checkLicenseTmpFileExists
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
	lcl_log(lcl_cLicenseController, lcl_vTrace, @"Checking if temp license file exists...");
	
    NSString *licensePath = [[LICENSE_TMP_DIR stringByAppendingPathComponent:LICENSE_FILE] stringByStandardizingPath];
    if (![manager fileExistsAtPath:licensePath])
    {
		lcl_log(lcl_cLicenseController, lcl_vTrace, @"No license file exists at path %@", licensePath);
		lcl_log(lcl_cLicenseController, lcl_vTrace, @"Failed");
        return NO;
    }
    
    NSString *sigPath = [[LICENSE_TMP_DIR stringByAppendingPathComponent:LICENSE_SIG] stringByStandardizingPath];
    if (![manager fileExistsAtPath:sigPath])
    {
		lcl_log(lcl_cLicenseController, lcl_vTrace, @"No signature file exists at path %@", sigPath);
		lcl_log(lcl_cLicenseController, lcl_vTrace, @"Failed");
        return NO;
    }
    
	lcl_log(lcl_cLicenseController, lcl_vTrace, @"Ok");
    return YES;
}

+ (BOOL)checkSignature:(NSString *)sigPath ofFile:(NSString *)filePath
{
	lcl_log(lcl_cLicenseController, lcl_vTrace, @"Checking file signature: %@", filePath);
	
    NSData *key = [PUB_KEY dataUsingEncoding:NSUTF8StringEncoding];
    NSString *keyPath = [[LICENSE_DIR stringByAppendingPathComponent:LICENSE_KEY_FILE] stringByStandardizingPath];
    [key writeToFile:keyPath atomically:YES];
    
    NSString *keyCheck = [NSString stringWithContentsOfFile:keyPath];
    if (![PUB_KEY isEqualToString:keyCheck])
    {
		lcl_log(lcl_cLicenseController, lcl_vTrace, @"Invalid public key.");
		lcl_log(lcl_cLicenseController, lcl_vTrace, @"Failed");
        return NO;
    }
    
	lcl_log(lcl_cLicenseController, lcl_vTrace, @"Starting openssl...");
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/openssl"];
    [task setArguments:[NSArray arrayWithObjects:@"dgst", @"-sha1", @"-verify", keyPath, @"-signature", sigPath, filePath, nil]];
    
    [task launch];
	int pid = [task processIdentifier];
	
	lcl_log(lcl_cLicenseController, lcl_vTrace, @"Started. pid = %d", pid);
    
	[task waitUntilExit];
    int status = [task terminationStatus];
    
	lcl_log(lcl_cLicenseController, lcl_vTrace, @"Terminated. status = %d", status);
	
    if (status == 0)
    {
		lcl_log(lcl_cLicenseController, lcl_vTrace, @"Ok");
        return YES;
    }
    
	lcl_log(lcl_cLicenseController, lcl_vTrace, @"Failed");
    return NO;
}

+ (BOOL)checkTmpSignature
{
    NSString *licensePath = [[LICENSE_TMP_DIR stringByAppendingPathComponent:LICENSE_FILE] stringByStandardizingPath];
    NSString *sigPath = [[LICENSE_TMP_DIR stringByAppendingPathComponent:LICENSE_SIG] stringByStandardizingPath];
    
    return [LicenseInstallController checkSignature:sigPath ofFile:licensePath];
}

+ (BOOL)checkProduct:(NSString *)product
{
    if ([product isEqualToString:@"Xilinus/MockSmtp"])
    {
        return YES;
    }
    
    if ([product isEqualToString:@"Xilinus/*"])
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)checkLicenseType:(NSString *)licenseType
{
    if ([licenseType isEqualToString:@"Trial"])
    {
        return YES;
    }
    
    if ([licenseType isEqualToString:@"Unlimited"])
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isNeedToCheckDate:(NSString *)licenseType
{
    if ([licenseType isEqualToString:@"Trial"])
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)checkDate:(NSDate *)expire
{
    if (!expire)
    {
        return NO;
    }
    
    if ([expire compare:[NSDate date]] == NSOrderedAscending)
    {
        return NO;
    }
    
    return YES;
}

+ (BOOL)unpackTmpFile:(NSString *)file
{
	lcl_log(lcl_cLicenseController, lcl_vTrace, @"Unpacking license file %@", file);
	
    NSString *licenseDir = [LICENSE_TMP_DIR stringByStandardizingPath];
    
	NSError *error = nil;
    if (![NSFileManager createDirectoryAtPathIfNotExists:licenseDir error:&error])
    {
		lcl_log(lcl_cLicenseController, lcl_vTrace, @"Cant create directory. Error: %@", error);
        return NO;
    }
    
    //tar -xzf license.key license.plist license.plist.sha1 -C dir
	lcl_log(lcl_cLicenseController, lcl_vTrace, @"Starting tar...");
	
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/tar"];
    [task setArguments:[NSArray arrayWithObjects:@"-xvzf", file, @"-C", licenseDir, @"license.plist", @"license.plist.sha1", nil]];
    
    [task launch];
	
	int pid = [task processIdentifier];
	lcl_log(lcl_cLicenseController, lcl_vTrace, @"Started. pid = %d", pid);
	
    [task waitUntilExit];
    int status = [task terminationStatus];
    
	lcl_log(lcl_cLicenseController, lcl_vTrace, @"Terminated. status = %d", status);
	
    if (status == 0)
    {
		lcl_log(lcl_cLicenseController, lcl_vTrace, @"Ok");
        return YES;
    }
    
	lcl_log(lcl_cLicenseController, lcl_vTrace, @"Failed");
    return NO;
}

- (IBAction)chooseFile:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setDelegate:self];
    
    if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton )
    {
        [mFileInfo setStringValue:@""];
        
        [mProduct setStringValue:@"-"];
        [mProduct setTextColor:[NSColor blackColor]];
        [mLicenseType setStringValue:@"-"];
        [mLicenseType setTextColor:[NSColor blackColor]];
        [mExpireText setStringValue:@"-"];
        [mExpireText setTextColor:[NSColor blackColor]];
        [mRegistered setStringValue:@"-"];
        [mEmail setStringValue:@"-"];
        
        [mActivateBtn setEnabled:NO];
        
        NSString *filename = [[openDlg filenames] objectAtIndex:0];
        [mFilePath setStringValue:filename];
        
        if (![LicenseInstallController unpackTmpFile:filename])
        {
            [mFileInfo setStringValue:@"This file has invalid format. Please, choose another one."];
            return;
        }
        
        if (![LicenseInstallController checkLicenseTmpFileExists])
        {
            [mFileInfo setStringValue:@"This file has invalid format. Please, choose another one."];
            return;
        }
        
        if (![LicenseInstallController checkTmpSignature])
        {
            [mFileInfo setStringValue:@"This file has invalid signature. Please, choose another one."];
            return;
        }
        
        NSString *licensePath = [[LICENSE_TMP_DIR stringByAppendingPathComponent:LICENSE_FILE] stringByStandardizingPath];
        NSDictionary *licenseDict = [NSDictionary dictionaryWithContentsOfFile:licensePath];
        
        NSString *product = [licenseDict objectForKey:@"Product"];
        NSString *type = [licenseDict objectForKey:@"LicenseType"];
        NSDate *expireDate = [licenseDict objectForKey:@"ExpirationDate"];
        NSString *registered = [licenseDict objectForKey:@"Username"];
        NSString *email = [licenseDict objectForKey:@"Email"];
        
        if (registered)
        {
            [mRegistered setStringValue:registered];
        }
        
        if (email)
        {
            [mEmail setStringValue:email];
        }
        
        BOOL valid = YES;
        
        if (![LicenseInstallController checkProduct:product])
        {
            [mProduct setStringValue:@"Invalid"];
            [mProduct setTextColor:[NSColor redColor]];
            valid = NO;
        }
        else
        {
            [mProduct setStringValue:product];
            [mProduct setTextColor:[NSColor blackColor]];
        }
        
        if (![LicenseInstallController checkLicenseType:type])
        {
            [mLicenseType setStringValue:@"Invalid"];
            [mLicenseType setTextColor:[NSColor redColor]];
            valid = NO;
        }
        else
        {
            [mLicenseType setStringValue:type];
            [mLicenseType setTextColor:[NSColor blackColor]];
        }
        
        if ([LicenseInstallController isNeedToCheckDate:type])
        {
            [mExpireText setStringValue:[NSString stringWithFormat:@"%@", expireDate]];
            
            if (![LicenseInstallController checkDate:expireDate])
            {
                [mExpireText setTextColor:[NSColor redColor]];
                valid = NO;
            }
        }
        
        [mActivateBtn setEnabled:valid];
        return;
    }
}

- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename
{
    NSString *ext = [filename pathExtension];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if ([manager fileExistsAtPath:filename isDirectory:&isDirectory])
    {
        if (isDirectory)
        {
            return YES;
        }
    }
    
    if ([ext isEqualToString:@"key"])
    {
        return YES;
    }
    
    return NO;
}

- (IBAction)activate:(id)sender
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *licenseTmpFile = [[LICENSE_TMP_DIR stringByAppendingPathComponent:LICENSE_FILE] stringByStandardizingPath];
    NSString *licenseFile = [[LICENSE_DIR stringByAppendingPathComponent:LICENSE_FILE] stringByStandardizingPath];
    NSString *sigTmpFile = [[LICENSE_TMP_DIR stringByAppendingPathComponent:LICENSE_SIG] stringByStandardizingPath];
    NSString *sigFile = [[LICENSE_DIR stringByAppendingPathComponent:LICENSE_SIG] stringByStandardizingPath];
    
    NSError *error = nil;
    [manager removeItemAtPath:licenseFile error:&error];
    [manager moveItemAtPath:licenseTmpFile toPath:licenseFile error:&error];
    [manager removeItemAtPath:sigFile error:&error];
    [manager moveItemAtPath:sigTmpFile toPath:sigFile error:&error];
    
    [mLicenseController updateInfo];
    [mPanel performClose:self];
}

@end
