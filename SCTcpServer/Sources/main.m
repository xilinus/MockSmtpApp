

#import <Foundation/Foundation.h>

#import "SCTcpServer.h"

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    SCTcpServer *server = [SCTcpServer tcpServer];
    
    NSConnection *connection = [NSConnection defaultConnection];
    [connection setRootObject:server];
    [connection registerName:@"com.screencustoms.tcp.server"];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    while ([server isRunning] && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    
    NSLog(@"exiting...");
    [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    NSLog(@"exit"); 
    [pool drain];
    return 0;
}
