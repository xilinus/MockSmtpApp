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

- (BOOL)startPrivilegedServer
{
    NSBundle *mb = [NSBundle mainBundle];
    NSString *srvPath = [mb pathForAuxiliaryExecutable:@"SCTcpServer"];
    OSStatus myStatus;
    
    AuthorizationRef myAuthorizationRef;
    myStatus = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &myAuthorizationRef);
    if (myStatus)
    {
        return NO;
    }
    
    myStatus = AuthorizationExecuteWithPrivileges(myAuthorizationRef, [srvPath UTF8String], kAuthorizationFlagDefaults, NULL, NULL);
    if (myStatus)
    {
        return NO;
    }
    
    AuthorizationFree(myAuthorizationRef, kAuthorizationFlagDefaults);
    return YES;
}

- (BOOL)startNonPrivilegedServer
{
    NSBundle *mb = [NSBundle mainBundle];
    NSString *srvPath = [mb pathForAuxiliaryExecutable:@"SCTcpServer"];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:srvPath];
    [task launch];
    
    return YES;
}

- (BOOL)startServer
{
    if (mPort < 1024)
    {
        return [self startPrivilegedServer];
    }
    else
    {
        return [self startNonPrivilegedServer];
    }
}

- (BOOL)start:(NSError **)error
{    
    id serverProxy = [[NSConnection rootProxyForConnectionWithRegisteredName:@"com.screencustoms.tcp.server" host:nil] retain];
    [serverProxy setProtocolForProxy:@protocol(SCTcpServer)];
    mServer = (id<SCTcpServer>) serverProxy;
    
    if (mServer)
    {
        @try
        {
            [mServer stop];
            while ([NSConnection rootProxyForConnectionWithRegisteredName:@"com.screencustoms.tcp.server" host:nil])
            {
                NSLog(@"wait");
            }        
        }
        @catch (NSException * e) {}
    }
    
    if (![self startServer])
    {
        return NO;
    }
    
    serverProxy = [[NSConnection rootProxyForConnectionWithRegisteredName:@"com.screencustoms.tcp.server" host:nil] retain];

#warning * It's sucks. Need to think about something more clever.
    while (!serverProxy)
    {
        NSLog(@"wait");
        serverProxy = [[NSConnection rootProxyForConnectionWithRegisteredName:@"com.screencustoms.tcp.server" host:nil] retain];
    }
    
    [serverProxy setProtocolForProxy:@protocol(SCTcpServer)];
    mServer = (id<SCTcpServer>) serverProxy;
    
    if (mServer)
    {
        [mServer setDelegate:self];
        if([mServer openPort:mPort])
        {
            return YES;
        }
        else
        {
            if (error)
            {
                *error = [NSError errorWithDomain:TcpServerErrorDomain code:kTcpServerCouldNotBindToIPv4Address userInfo:nil];
            }
            return NO;
        }

    }
    else
    {
        NSLog(@"server is null");
        return NO;
    }
    
    return YES;
}

- (BOOL)stop
{
    @try
    {
        [mServer stop];
        while ([NSConnection rootProxyForConnectionWithRegisteredName:@"com.screencustoms.tcp.server" host:nil])
        {
            NSLog(@"wait");
        }        
    }
    @catch (NSException * e) {}
    
    return YES;
}

- (void)handleNewConnection:(id<SCTcpConnection>)connection
{

}

- (void)tcpServer:(id<SCTcpServer>)server didOpenConnection:(id<SCTcpConnection>)connection
{
    [self handleNewConnection:connection];
}

- (void)tcpServer:(id<SCTcpServer>)server didCloseConnection:(id<SCTcpConnection>)connection
{
}

- (void)dealloc {
    
    [self stop];

    [mDomain release];
    [mName release];
    [mType release];
    
    [super dealloc];
}


@end
