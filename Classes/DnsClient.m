//
//  DnsClient.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 04/03/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import "DnsClient.h"

@interface DnsClient(Private)

- (void)queryMailExchangerForDomain:(NSString *)domain;

@property (nonatomic, readonly) NSMutableDictionary *mxCache;

@end

@implementation DnsClient

static DnsClient *sSharedClient = nil;

+ (DnsClient *)sharedClient
{
    if (sSharedClient)
    {
        return sSharedClient;
    }
    
    sSharedClient = [[DnsClient alloc] init];
    return sSharedClient;
}

- (id)init
{
    if (self = [super init])
    {
        mMxCache = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (NSString *)mailExchangerForDomain:(NSString *)domain
{
    NSString *exchanger = [mMxCache objectForKey:domain];
    if (exchanger)
    {
        return exchanger;
    }
    
    [self queryMailExchangerForDomain:domain];
    
    exchanger = [mMxCache objectForKey:domain];
    return exchanger;
}

@end

#include <dns_sd.h>
#include <unistd.h>
#include <DNSServiceDiscovery/DNSServiceDiscovery.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#define BIND_8_COMPAT 1
#include <nameser.h>

#define MAX_DOMAIN_LABEL 63
#define MAX_DOMAIN_NAME 255
#define MAX_CSTRING 2044

typedef struct { u_char c[64]; } Domainlabel;
typedef struct { u_char c[256]; } Domainname;

static void QueryCallback(const DNSServiceRef DNSServiceRef,
                          const DNSServiceFlags flags,
                          const u_int32_t interfaceIndex,
                          const DNSServiceErrorType errorCode,
                          const char *name,
                          const u_int16_t rrtype,
                          const u_int16_t rrclass,
                          const u_int16_t rdlen,
                          const void *rdata,
                          const u_int32_t ttl,
                          void *context);

static char* ConvertDomainNameToCString(const Domainname * const name, char *ptr, char esc);
static char* ConvertDomainLabelToCString(const Domainlabel * const label, char *ptr, char esc);

@implementation DnsClient(Private)

- (void)queryMailExchangerForDomain:(NSString *)domain
{
    domain = [NSString stringWithFormat:@"%@.", domain];
    
    DNSServiceRef sdr = NULL;
    DNSServiceErrorType err = kDNSServiceErr_NoError;
    
    err = DNSServiceQueryRecord(&sdr,
                                0, //kDNSServiceFlagsLongLivedQuery,
                                0,
                                [domain UTF8String],
                                kDNSServiceType_MX,
                                kDNSServiceClass_IN,
                                QueryCallback,
                                self);
    
    if (err) 
    {
        return;
    }
    
    int fd = DNSServiceRefSockFD(sdr);
    
    fd_set readset;
    int result = 0;
    struct timeval tv;
    
    FD_ZERO(&readset);
    FD_SET(fd, &readset);
    
    tv.tv_sec = 5;
    tv.tv_usec = 0;
    
    result = select(fd + 1, &readset, NULL, NULL, &tv);
    
    if (result > 0 && FD_ISSET(fd, &readset))
    {
        DNSServiceProcessResult(sdr);
    }
    
    DNSServiceRefDeallocate(sdr);
}

- (NSMutableDictionary *)mxCache
{
    return mMxCache;
}

@end

static void QueryCallback(const DNSServiceRef DNSServiceRef,
                          const DNSServiceFlags flags,
                          const u_int32_t interfaceIndex,
                          const DNSServiceErrorType errorCode,
                          const char *name,
                          const u_int16_t rrtype,
                          const u_int16_t rrclass,
                          const u_int16_t rdlen,
                          const void *rdata,
                          const u_int32_t ttl,
                          void *context)
{
    if (errorCode)
    {
        return;
    }
    
    DnsClient *dnsClient = (DnsClient *)context;
    
    NSString *domain = [NSString stringWithUTF8String:name];
    domain = [domain substringToIndex:([domain length] - 1)];
    
    NSString *exchanger = [dnsClient.mxCache objectForKey:domain];
    if (exchanger)
    {
        return;
    }
    
    char exchanger_c[MAX_CSTRING];
    ConvertDomainNameToCString((Domainname *)(rdata + 2), exchanger_c, 0);
    
    exchanger = [NSString stringWithUTF8String:exchanger_c];
    exchanger = [exchanger substringToIndex:([exchanger length] - 1)];
    
    [dnsClient.mxCache setObject:exchanger forKey:domain];
}

static char* ConvertDomainNameToCString(const Domainname * const name, char *ptr, char esc)
{
    const u_char *src = name->c;
    const u_char *const max = name->c + MAX_DOMAIN_NAME;
    
    if (*src == 0)
    {
        *ptr++ = '.';
    }
    
    while (*src)
    {
        if (src + 1 + *src >= max)
        {
            return NULL;
        }
        
        ptr = ConvertDomainLabelToCString((const Domainlabel *)src, ptr, esc);
        if (!ptr)
        {
            return(NULL);
        }
        
        src += 1 + *src;
        *ptr++ = '.';
    }
    
    *ptr++ = 0;
    return ptr;
}

static char* ConvertDomainLabelToCString(const Domainlabel * const label, char *ptr, char esc)
{
    const u_char *src = label->c;
    const u_char len = *src++;
    const u_char *const end = src + len;
    
    if (len > MAX_DOMAIN_LABEL)
    {
        return(NULL);
    }
    
    while (src < end)
    {
        u_char c = *src++;
        if (esc)
        {
            if (c == '.')
            {
                *ptr++ = esc;
            
            }
            else if (c <= ' ')
            {
                *ptr++ = esc;
                *ptr++ = (char)('0' + (c / 100));
                *ptr++ = (char)('0' + (c / 10) % 10);
                c = (u_char)('0' + c % 10);
            }
        }
        *ptr++ = (char)c;
    }
    *ptr = 0;
    return ptr;
}
