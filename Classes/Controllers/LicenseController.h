//
//  LicenseController.h
//  MockSmtp
//
//  Created by Oleg Shnitko on 07/01/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LicenseController : NSObject
{
@private
    
    NSString *mProduct;
    NSString *mType;
    NSDate *mExpiration;
    NSString *mUsername;
    NSString *mEmail;
    
}

@property (nonatomic, retain) NSString *product;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSDate *expiration;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *email;

@end
