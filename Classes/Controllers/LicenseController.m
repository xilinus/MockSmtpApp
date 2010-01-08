//
//  LicenseController.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 07/01/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import "LicenseController.h"

#define LICENSE_DIR @"~/.mocksmtp"
#define LICENSE_FILE @"license.plist"

@implementation LicenseController

@synthesize product = mProduct;
@synthesize type = mType;
@synthesize expiration = mExpiration;
@synthesize username = mUsername;
@synthesize email = mEmail;

- (void)updateInfo
{
    NSString *licensePath = [[LICENSE_DIR stringByAppendingPathComponent:LICENSE_FILE] stringByStandardizingPath];
    NSDictionary *licenseDict = [NSDictionary dictionaryWithContentsOfFile:licensePath];
    
    self.product = [licenseDict objectForKey:@"Product"];
    self.type = [licenseDict objectForKey:@"LicenseType"];
    self.expiration = [licenseDict objectForKey:@"ExpirationDate"];
    self.username = [licenseDict objectForKey:@"Username"];
    self.email = [licenseDict objectForKey:@"Email"];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    [self updateInfo];
}

@end
