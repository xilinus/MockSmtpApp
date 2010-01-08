//
//  SCTcpConnection.m
//  SCTcpServer
//
//  Created by Oleg Shnitko on 23/12/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#import "SCTcpConnection.h"
#import "SCTcpServer.h"

@implementation SCTcpConnection

@synthesize delegate = mDelegate;
@synthesize server = mServer;
@synthesize peerAddress = mPeerAddress;
@synthesize isValid = mIsValid;

- (id)initWithPeerAddress:(NSData *)address
              inputStream:(NSInputStream *)inputStream
             outputStream:(NSOutputStream *)outputStream
                forServer:(SCTcpServer *)server
{
    if (self = [super init])
    {
        mServer = server;
        mPeerAddress = [address copy];
        
        mInputStream = [inputStream retain];
        mOutputStream = [outputStream retain];
        
        [mInputStream setDelegate:self];
        [mOutputStream setDelegate:self];
        
        [mInputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [mOutputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [mInputStream open];
        [mOutputStream open];
        
        mInputBuffer = [[NSMutableData alloc] init];
        mOutputBuffer = [[NSMutableData alloc] init];
        
        mIsValid = YES;
    }
    
    return self;    
}

- (NSString *)getAddress
{
    struct sockaddr_in addr4;
    memcpy(&addr4, [mPeerAddress bytes], sizeof(addr4));
    struct in_addr a = addr4.sin_addr;
    NSString *addressString = [NSString stringWithCString:inet_ntoa(a)];
    return addressString;
}

- (void)processIncomingBytes
{
    NSUInteger inputLength = [mInputBuffer length];
    if (inputLength > 0)
    {
        //NSLog(@"Client: %@", [[NSString alloc] initWithData:mInputBuffer encoding:NSASCIIStringEncoding]);
        //NSUInteger processed = 0;
        //NSUInteger processed = [mSession processData:mInputBuffer];
        
        //NSInteger rest = inputLength - processed;
        //if (rest > 0)
        //{
        //    memmove([mInputBuffer mutableBytes], [mInputBuffer mutableBytes] + processed, rest);
        //}
        
        if ([mDelegate respondsToSelector:@selector(tcpConnection:didReceiveData:)])
        {
            [mDelegate tcpConnection:self didReceiveData:mInputBuffer];
        }
        
        [mInputBuffer setLength:0];
    }
}

- (void)processOutgoingBytes
{
    if ([mOutputStream hasSpaceAvailable])
    {
        NSUInteger outputLength = [mOutputBuffer length];
        if (outputLength > 0)
        {
            //NSLog(@"Server: %@", [[NSString alloc] initWithData:mOutputBuffer encoding:NSASCIIStringEncoding]);
            NSInteger written = [mOutputStream write:[mOutputBuffer bytes] maxLength:outputLength];
            
            NSInteger rest = outputLength - written;
            if (rest > 0)
            {
                memmove([mOutputBuffer mutableBytes], [mOutputBuffer mutableBytes] + written, rest);
            }
            
            [mOutputBuffer setLength:rest];
        }
    }
}

- (void)read
{
    uint8_t buffer[16384];
    uint8_t *bytes = NULL;
    
    NSUInteger bytesLength = 0;
    if (![mInputStream getBuffer:&bytes length:&bytesLength])
    {
        NSInteger read = [mInputStream read:buffer maxLength:sizeof(buffer)];
        bytes = buffer;
        bytesLength = read > 0 ? read : 0;
    }
    
    if (bytesLength > 0)
    {
        [mInputBuffer appendBytes:bytes length:bytesLength];
        [self processIncomingBytes];
    }
}

- (void)writeData:(NSData *)data
{
    [mOutputBuffer appendData:data];
    [self processOutgoingBytes];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent
{
    switch(streamEvent)
    {
        case NSStreamEventHasBytesAvailable:
        {
            [self read];
            break;
        }
            
        case NSStreamEventHasSpaceAvailable:
        {
            [self processOutgoingBytes];
            break;
        }
            
        /*case NSStreamEventOpenCompleted:
        {
            if (stream == mOutputStream)
            {
                if ([mDelegate respondsToSelector:@selector(smtpServer:didOpenConnection:)])
                {
                    [mDelegate smtpServer:mServer didOpenConnection:self];
                }
                
                //[mSession open];
            }
            
            break;
        }*/
            
        case NSStreamEventEndEncountered:
        {
            [self invalidate];
            break;
        }
            
        case NSStreamEventErrorOccurred:
        {
            NSLog(@"SmtpServer stream error: %@", [stream streamError]);
            break;
        }
            
        default:
            break;
    }
}

- (void)invalidate
{
    if (mIsValid)
    {
        mIsValid = NO;
        
        [mInputStream close];
        [mOutputStream close];
        
        [mInputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [mOutputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [mInputStream setDelegate:nil];
        [mOutputStream setDelegate:nil];
        
        [mInputStream release];
        [mOutputStream release];
        
        mInputStream = nil;
        mOutputStream = nil;
        
        [mInputBuffer release];
        [mOutputBuffer release];
        
        mInputBuffer = nil;
        mOutputBuffer = nil;
        
        
        [mServer closeConnection:self];
    }
}

- (void)dealloc
{
    [self invalidate];
    [mPeerAddress release];
    
    [super dealloc];
}

@end
