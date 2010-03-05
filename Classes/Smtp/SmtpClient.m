//
//  SmtpClient.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 04/03/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import "SmtpClient.h"
#import "Message.h"
#import "DnsClient.h"
#import "EDMailAgent.h"
#import "NSString+MessageUtils.h"
#import "NSHost+Extensions.h"

@interface Envelope : NSObject
{
@private
    
    NSString *mDomain;
    NSString *mSender;
    NSMutableArray *mReceivers;
    NSData *mMail;
}

+ (NSArray *)envelopesFromMessage:(Message *)message;

@property (nonatomic, retain) NSString *domain;
@property (nonatomic, retain) NSString *sender;
@property (nonatomic, retain) NSMutableArray *receivers;
@property (nonatomic, retain) NSData *mail;

@end

@implementation Envelope

@synthesize domain = mDomain;
@synthesize sender = mSender;
@synthesize receivers = mReceivers;
@synthesize mail = mMail;

+ (NSArray *)envelopesFromMessage:(Message *)message
{
    NSMutableDictionary *envelopes = [[NSMutableDictionary alloc] init];
    
    NSString *from = [message from];
    NSString *to = [message to];
    NSString *cc = [message cc];
    NSData *mail = [message transferData];
    
    NSArray *senders = [from addressListFromEMailString];
    NSString *sender = [senders objectAtIndex:0];
    
    NSArray *toReceivers = [to addressListFromEMailString];
    NSArray *ccReceivers = [cc addressListFromEMailString];
    
    NSMutableArray *receivers = [[NSMutableArray alloc] init];
    [receivers addObjectsFromArray:toReceivers];
    [receivers addObjectsFromArray:ccReceivers];
    
    NSUInteger count = [receivers count];
    for (NSUInteger i = 0; i < count; i++)
    {
        NSString *receiver = [receivers objectAtIndex:i];
        NSString *domain = [receiver domainFromAddressString];
        
        if (!domain)
        {
            NSHost *currentHost = [NSHost currentHost];
            if (!(domain = [currentHost domain]))
            {
                if (!(domain = [NSHost localDomain]))
                {
                    domain = @"";
                }
            }
        }
        
        Envelope *envelope = [envelopes objectForKey:domain];
        if (!envelope)
        {
            envelope = [[Envelope alloc] init];
            envelope.domain = domain;
            envelope.sender = sender;
            envelope.mail = mail;
            [envelopes setObject:envelope forKey:domain];
        }
        
        if (![envelope.receivers containsObject:receiver])
        {
            [envelope.receivers addObject:receiver];
        }
    }
    
    NSArray *result = [envelopes allValues];
    
    return result;
}

- (id)init
{
    if (self = [super init])
    {
        mReceivers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end

@interface SmtpClient (Private)

- (void)addMessageToQueue:(Message *)message;
- (Envelope *)dequeueMessage;

- (void)startDelivering;
- (void)stopDelivering;

- (void)deliverFirstMessage;
- (void)deliverMessage:(Envelope *)message;

- (void)deliverMail:(NSData *)mail from:(NSString *)sender to:(NSArray *)receivers forDomain:(NSString *)domain;
- (void)deliverMail:(NSData *)mail from:(NSString *)sender to:(NSArray *)receivers usingExchanger:(NSString *)exchanger;

- (void)updateStatus;

@end

@implementation SmtpClient

@synthesize taskCount = mTaskCount;
@synthesize processingCount = mProcessingCount;
@synthesize waitingCount = mWaintingCount;
@synthesize sendingCount = mSendingCount;
@synthesize sentCount = mSentCount;
@synthesize failCount = mFailCount;

@synthesize delivering = mDelivering;

@synthesize status = mStatus;

@synthesize logController = mLogController;

- (void)awakeFromNib
{
    mQueue = [[NSMutableArray alloc] init];
    [self updateStatus];
}

- (void)deliverMessages:(NSArray *)messages
{
    for (NSUInteger i = 0; i < [messages count]; i++)
    {
        Message *message = (Message *)[messages objectAtIndex:i];
        [self addMessageToQueue:message];
    }
    
    [self startDelivering];
}

@end

@implementation SmtpClient (Private)

- (void)_log:(NSString *)msg
{
    [mLogController logComponent:@"Mailer" info:msg];
}

- (void)_error:(NSString *)msg
{
    [mLogController logComponent:@"Mailer" error:msg];
}

- (void)log:(NSString *)msg
{
    NSLog(@"%@", msg);
    [self performSelectorOnMainThread:@selector(_log:) withObject:msg waitUntilDone:NO];
    //[mLogController logComponent:@"Mailer" info:msg];
}

- (void)error:(NSString *)msg
{
    NSLog(@"%@", msg);
    [self performSelectorOnMainThread:@selector(_error:) withObject:msg waitUntilDone:NO];
    //[mLogController logComponent:@"Mailer" error:msg];
}

- (void)addMessageToQueue:(Message *)message
{
    NSArray *envelopes = [Envelope envelopesFromMessage:message];
    
    @synchronized (mQueue)
    {
        [mQueue addObjectsFromArray:envelopes];
    }
    
    self.taskCount += [envelopes count];
    self.processingCount += [envelopes count];
    self.waitingCount += [envelopes count];
    [self updateStatus];
}

- (Envelope *)dequeueMessage
{
    Envelope *message = nil;
    
    @synchronized (mQueue)
    {
        if ([mQueue count] == 0)
        {
            return nil;
        }
        
        message = [mQueue objectAtIndex:0];
        [mQueue removeObjectAtIndex:0];
    }
    
    self.waitingCount -= 1;
    self.sendingCount += 1;
    [self updateStatus];
    
    return message;
}

- (void)startDelivering
{
    if (self.delivering)
    {
        return;
    }
    
    self.delivering = YES;
    
    self.taskCount = [mQueue count];
    self.processingCount = [mQueue count];
    self.waitingCount = [mQueue count];
    self.sendingCount = 0;
    self.sentCount = 0;
    self.failCount = 0;
    [self updateStatus];
    
    [self performSelectorInBackground:@selector(deliverFirstMessage) withObject:nil];
}

- (void)stopDelivering
{
    self.delivering = NO;
    [self updateStatus];
}

- (void)deliverFirstMessage
{
    Envelope *message = [self dequeueMessage];
    
    if (!message)
    {
        [self stopDelivering];
        return;
    }
    
    [self deliverMessage:message];
    //[self deliverFirstMessage];
    [self performSelectorInBackground:@selector(deliverFirstMessage) withObject:nil];
}

- (void)deliverMessage:(Envelope *)message
{
    NSString *domain = message.domain;
    NSString *sender = message.sender;
    NSArray *receivers = message.receivers;
    NSData *mail = message.mail;
    
    [self log:[NSString stringWithFormat:@"Sending mail from: %@", sender]];
    NSMutableString *toString = [[NSMutableString alloc] initWithString:@"To:"];
    for (NSString *address in receivers)
    {
        [toString appendString:[NSString stringWithFormat:@" %@", address]];
    }
    [self log:toString];
    
    [self deliverMail:mail from:sender to:receivers forDomain:domain];
}

- (void)deliverMail:(NSData *)mail from:(NSString *)sender to:(NSArray *)receivers forDomain:(NSString *)domain
{
    [self log:[NSString stringWithFormat:@"Querying mail exchanger for domain <%@>...", domain]];
    
    @try
    {
        DnsClient *dnsClient = [DnsClient sharedClient];
        NSString *exchanger = [dnsClient mailExchangerForDomain:domain];
        
        if (!exchanger)
        {
            self.processingCount -= 1;
            self.sendingCount -= 1;
            self.failCount += 1;
            [self updateStatus];
            
            [self error:@"MX record not found"];
            return;
        }
        
        [self log:[NSString stringWithFormat:@"Exchanger: %@", exchanger]];
        [self deliverMail:mail from:sender to:receivers usingExchanger:exchanger];        
    }
    @catch (NSException * e)
    {
        self.processingCount -= 1;
        self.sendingCount -= 1;
        self.failCount += 1;
        [self updateStatus];
        
        [self error:[NSString stringWithFormat:@"%@", e]];
    }
}

- (void)deliverMail:(NSData *)mail from:(NSString *)sender to:(NSArray *)receivers usingExchanger:(NSString *)exchanger
{
    @try
    {
        [self log:@"Sending mail data..."];
        
        EDMailAgent *agent = [EDMailAgent mailAgentForRelayHostWithName:exchanger];
        [agent sendMail:mail from:sender to:receivers];
        
        self.processingCount -= 1;
        self.sendingCount -= 1;
        self.sentCount += 1;
        [self updateStatus];
        
        [self log:@"Done."];
    }
    @catch (NSException * e)
    {
        self.processingCount -= 1;
        self.sendingCount -= 1;
        self.failCount += 1;
        [self updateStatus];
        
        [self error:[NSString stringWithFormat:@"%@", e]];
    }
}

- (void)updateStatus
{
    
    if (self.taskCount == 0)
    {
        NSMutableAttributedString *newStatus = [[NSMutableAttributedString alloc] initWithString:@"Delivering queue is empty."];
        NSRange range = NSMakeRange(0, [newStatus length]);
        [newStatus setAlignment:NSRightTextAlignment range:range];
        
        self.status = newStatus;
        return;
    }
    
    NSMutableString *newStatus = [[NSMutableString alloc] init];
    
    if (self.delivering)
    {
        [newStatus appendString:@"Delivering "];
    }
    else
    {
        [newStatus appendString:@"Delivered "];
    }
    
    [newStatus appendString:[NSString stringWithFormat:@"(%d/%d)", self.sentCount, self.taskCount]];
    
    if (self.failCount != 0)
    {
        [newStatus appendString:[NSString stringWithFormat:@" Failed: %d", self.failCount]];
    }
    
    NSMutableAttributedString *status = [[NSMutableAttributedString alloc] initWithString:newStatus];
    NSRange range = NSMakeRange(0, [status length]);
    [status setAlignment:NSRightTextAlignment range:range];
    
    self.status = status;
}

@end
