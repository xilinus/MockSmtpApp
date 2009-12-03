//
//  TcpServer.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 19/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import "TcpServer.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

NSString * const TcpServerErrorDomain = @"TcpServerErrorDomain";

@implementation TcpServer

@synthesize delegate = mDelegate;

@synthesize domain = mDomain;
@synthesize name = mName;
@synthesize type = mType;
@synthesize port = mPort;

- (id)init
{
    if (self = [super init])
    {
    }
    
    return self;
}

static void TcpServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);

- (BOOL)start:(NSError **)error
{
    CFSocketContext socketCtxt = {0, self, NULL, NULL, NULL};
    
    mIPv4socket = CFSocketCreate(kCFAllocatorDefault,
                                 PF_INET,
                                 SOCK_STREAM,
                                 IPPROTO_TCP,
                                 kCFSocketAcceptCallBack,
                                 (CFSocketCallBack)&TcpServerAcceptCallBack,
                                 &socketCtxt);
    
    if (mIPv4socket == NULL)
    {
        if (error)
        {
            *error = [[NSError alloc] initWithDomain:TcpServerErrorDomain code:kTcpServerNoSocketsAvailable userInfo:nil];
        }
        
        if (mIPv4socket)
        {
            CFRelease(mIPv4socket);
            mIPv4socket = NULL;
        }
        
        return NO;
    }
    
    int yes = 1;
    setsockopt(CFSocketGetNative(mIPv4socket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
    
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = htons(mPort);
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
    
    if (CFSocketSetAddress(mIPv4socket, (CFDataRef)address4) != kCFSocketSuccess)
    {
        if (error)
        {
            *error = [[NSError alloc] initWithDomain:TcpServerErrorDomain code:kTcpServerCouldNotBindToIPv4Address userInfo:nil];
        }
        
        if (mIPv4socket)
        {
            CFRelease(mIPv4socket);
            mIPv4socket = NULL;
        }
        
        return NO;
    }
    
    if (mPort == 0)
    {
        NSData *addr = [(NSData *)CFSocketCopyAddress(mIPv4socket) autorelease];
        memcpy(&addr4, [addr bytes], [addr length]);
        mPort = ntohs(addr4.sin_port);
    }
    
    CFRunLoopRef cfRunLoop = CFRunLoopGetCurrent();
    CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, mIPv4socket, 0);
    CFRunLoopAddSource(cfRunLoop, source4, kCFRunLoopDefaultMode);
    CFRelease(source4);
    
    if (mType != nil)
    {
        NSString *publishingDomain = mDomain ? mDomain : @"";
        NSString *publishingName = nil;
        
        if (mName != nil)
        {
            publishingName = mName;
        }
        else
        {
            NSString *thisHostName = [[NSProcessInfo processInfo] hostName];
            if ([thisHostName hasSuffix:@".local"])
            {
                publishingName = [thisHostName substringToIndex:([thisHostName length] - 6)];
            }
        }
        
        mNetService = [[NSNetService alloc] initWithDomain:publishingDomain type:mType name:publishingName port:mPort];
        [mNetService publish];
    }
    
    return YES;
}

- (BOOL)stop
{
    [mNetService stop];
    [mNetService release];
    mNetService = nil;

    CFSocketInvalidate(mIPv4socket);
    CFRelease(mIPv4socket);
    mIPv4socket = NULL;
    
    return YES;
}

- (void)handleNewConnectionFromAddress:(NSData *)address
                           inputStream:(NSInputStream *)inputStream
                          outputStream:(NSOutputStream *)outputStream
{
    if (mDelegate && [mDelegate respondsToSelector:@selector(tcpServer:didReceiveConnectionFrom:inputStream:outputStream:)])
    { 
        [mDelegate tcpServer:self didReceiveConnectionFromAddress:address inputStream:inputStream outputStream:outputStream];
    }
}

- (void)dealloc {
    
    [self stop];

    [mDomain release];
    [mName release];
    [mType release];
    
    [super dealloc];
}

static void TcpServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    TcpServer *server = (TcpServer *)info;
    if (kCFSocketAcceptCallBack == type)
    { 
        CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
        
        uint8_t name[SOCK_MAXADDRLEN];
        socklen_t namelen = sizeof(name);
        
        NSData *peer = nil;
        if (getpeername(nativeSocketHandle, (struct sockaddr *)name, &namelen) == 0)
        {
            peer = [NSData dataWithBytes:name length:namelen];
        }
        
        CFReadStreamRef readStream = NULL;
        CFWriteStreamRef writeStream = NULL;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStream, &writeStream);
        
        if (readStream && writeStream)
        {
            CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            [server handleNewConnectionFromAddress:peer inputStream:(NSInputStream *)readStream outputStream:(NSOutputStream *)writeStream];
        }
        else
        {
            close(nativeSocketHandle);
        }
        
        if (readStream) CFRelease(readStream);
        if (writeStream) CFRelease(writeStream);
    }
}

@end
