//
//  DnsClient.h
//  MockSmtp
//
//  Created by Oleg Shnitko on 04/03/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DnsClient : NSObject
{
@private
    
    NSMutableDictionary *mMxCache;
}

+ (DnsClient *)sharedClient;

- (NSString *)mailExchangerForDomain:(NSString *)domain;

@end
