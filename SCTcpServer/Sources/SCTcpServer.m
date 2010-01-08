//
//  SCTcpServer.m
//  SCTcpServer
//
//  Created by Oleg Shnitko on 23/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "SCTcpServer.h"
#import "SCTcpConnection.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

static void TcpServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);

@implementation SCTcpServer

@synthesize delegate = mDelegate;
@synthesize isRunning = mIsRunning;

+ (id)tcpServer
{
    return [[SCTcpServer alloc] init];
}

- (id)init
{
    if (self = [super init])
    {
        mConnections = [[NSMutableArray alloc] init];
        mIsRunning = YES;
    }
    
    return self;
}

- (BOOL)openPort:(UInt16)port
{
    NSLog(@"openPort");
    
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
        return NO;
    }
    
    int yes = 1;
    setsockopt(CFSocketGetNative(mIPv4socket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
    
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = htons(port);
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
    
    if (CFSocketSetAddress(mIPv4socket, (CFDataRef)address4) != kCFSocketSuccess)
    {
        return NO;
    }
    
    CFRunLoopRef cfRunLoop = CFRunLoopGetCurrent();
    CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, mIPv4socket, 0);
    CFRunLoopAddSource(cfRunLoop, source4, kCFRunLoopDefaultMode);
    CFRelease(source4);
    
    return YES;
}

- (void)closePort:(UInt16)port
{
    NSLog(@"closePort");
    
    if ([mDelegate respondsToSelector:@selector(tcpServer:didCloseConnection:)])
    {
        [mDelegate tcpServer:self didCloseConnection:nil];
    }
}

- (void)stop
{
    NSLog(@"stop");
    mIsRunning = NO;
}

- (void)makeConnectionFromAddress:(NSData *)address 
                      inputStream:(NSInputStream *)inputStream
                     outputStream:(NSOutputStream *)outputStream
{
    SCTcpConnection *connection = [[SCTcpConnection alloc] initWithPeerAddress:address
                                                                 inputStream:inputStream
                                                                outputStream:outputStream
                                                                   forServer:self];
    [mConnections addObject:connection];
    
    if ([mDelegate respondsToSelector:@selector(tcpServer:didOpenConnection:)])
    {
        [mDelegate tcpServer:self didOpenConnection:connection];
    }
    
    [connection release];
}

- (void)handleNewConnectionFromAddress:(NSData *)address
                           inputStream:(NSInputStream *)inputStream
                          outputStream:(NSOutputStream *)outputStream
{
    [self makeConnectionFromAddress:address inputStream:inputStream outputStream:outputStream];
}

- (void)closeConnection:(SCTcpConnection *)connection
{
    if (![mConnections containsObject:connection])
    {
        return;
    }
    
    if ([connection isValid])
    {
        [connection invalidate];
        return;
    }
    
    if ([mDelegate respondsToSelector:@selector(tcpServer:didCloseConnection:)])
    {
        [mDelegate tcpServer:self didCloseConnection:connection];
    }
    
    [mConnections removeObject:connection];
}

@end

static void TcpServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    SCTcpServer *server = (SCTcpServer *)info;
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

