//---------------------------------------------------------------------------------------
//  EDMailAgent.h created by erik on Fri 21-Apr-2000
//  $Id: EDMailAgent.h,v 2.1 2002/08/19 00:05:41 erik Exp $
//
//  Copyright (c) 2000,2008 by Erik Doernenburg. All rights reserved.
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Erik Doernenburg in all documents and publicity
//  pertaining to direct or indirect use of this code or its derivatives.
//
//  THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
//  SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
//  "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
//  DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
//  OR OF ANY DERIVATIVE WORK.
//---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@class EDInternetMessage;

struct _EDMAFlags
{
    unsigned 	skipExtensionTest : 1;
	unsigned	usesSecureConnections : 1;
	unsigned	allowsAnyRootCertificate : 1;
	unsigned	allowsExpiredCertificates : 1;
};


@interface EDMailAgent : NSObject
{
    NSHost 				*relayHost;		/*" All instance variables are private. "*/
	int					port;			/*" "*/
	struct _EDMAFlags 	flags;			/*" "*/		
	NSDictionary		*authInfo;		/*" "*/
}


/*" Creating mail agent instances "*/

+ (id)mailAgentForRelayHostWithName:(NSString *)aName;
+ (id)mailAgentForRelayHostWithName:(NSString *)aName port:(int)aPort;

/*" Configuring the mail agent "*/

- (void)setRelayHostByName:(NSString *)hostname;
- (void)setRelayHost:(NSHost *)aHost;
- (NSHost *)relayHost;

- (void)setPort:(int)aPort;
- (int)port;

- (void)setSkipsExtensionTest:(BOOL)flag;
- (BOOL)skipsExtensionTest;

- (void)setUsesSecureConnections:(BOOL)flag;
- (BOOL)usesSecureConnections;

- (void)setAllowsAnyRootCertificate:(BOOL)allowed;
- (BOOL)allowsAnyRootCertificate;

- (void)setAllowsExpiredCertificates:(BOOL)allowed;
- (BOOL)allowsExpiredCertificates;

- (void)setAuthInfo:(NSDictionary *)infoDictionary;
- (NSDictionary *)authInfo;

/*" Sending messages "*/

- (void)sendMail:(NSData *)data from:(NSString *)sender to:(NSArray *)recipients;

- (void)sendMailWithHeaders:(NSDictionary *)userHeaders andBody:(NSString *)body;
- (void)sendMailWithHeaders:(NSDictionary *)userHeaders body:(NSString *)body andAttachment:(NSData *)attData withName:(NSString *)attName;
- (void)sendMailWithHeaders:(NSDictionary *)userHeaders body:(NSString *)body andAttachments:(NSArray *)attList;

- (void)sendMessage:(EDInternetMessage *)message;

@end

extern NSString *EDMailAgentException;
extern NSString *EDSMTPUserName;
extern NSString *EDSMTPPassword;

extern NSString *EDMailTo;
extern NSString *EDMailCC;
extern NSString *EDMailBCC;
extern NSString *EDMailFrom;
extern NSString *EDMailSender;
extern NSString *EDMailSubject;
