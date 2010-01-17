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
@synthesize affiliate = mAffiliate;

- (void)updateInfo
{
    NSString *licensePath = [[LICENSE_DIR stringByAppendingPathComponent:LICENSE_FILE] stringByStandardizingPath];
    NSDictionary *licenseDict = [NSDictionary dictionaryWithContentsOfFile:licensePath];
    
    self.product = [licenseDict objectForKey:@"Product"];
    self.type = [licenseDict objectForKey:@"LicenseType"];
    self.expiration = [licenseDict objectForKey:@"ExpirationDate"];
    self.username = [licenseDict objectForKey:@"Username"];
    self.email = [licenseDict objectForKey:@"Email"];
    self.affiliate = [licenseDict objectForKey:@"Affiliate"];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    [self updateInfo];
}

- (IBAction)buy:(id)sender
{
    NSWorkspace* ws = [NSWorkspace sharedWorkspace];
    NSString* myurl = @"http://mocksmtpapp.com/buy";
    if (self.affiliate)
	{
		myurl = [myurl stringByAppendingString:@"?affiliate_id="];
		myurl = [myurl stringByAppendingString:self.affiliate];
	}
		
    NSURL* url = [NSURL URLWithString:myurl];
    
    [ws openURL:url];
}

@end
