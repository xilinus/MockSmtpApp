// 
//  Message.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 18/11/2009.
//  Copyright 2009 Natural Devices, Inc.. All rights reserved.
//

#import "Message.h"

#import "User.h"
#import "Folder.h"
#import "MessagePart.h"
#import "MessageAttachment.h"

#import "EDMessage.h"

@implementation Message 

@dynamic read;
@dynamic transferData;
@dynamic user;
@dynamic folder;

- (EDInternetMessage *)edMessage
{
    if (mEdMessage)
    {
        return mEdMessage;
    }
    
    mEdMessage = [[EDInternetMessage alloc] initWithTransferData:[self transferData]];
    
    return mEdMessage;
}

- (NSString *)valueForHeaderField:(NSString *)field
{
    NSString *body;
    
    if (body = [self.edMessage bodyForHeaderField:field])
    {
        return [[[EDTextFieldCoder decoderWithFieldBody:body] text] copy];
    }
    
    return nil;
}

- (void)parseHeader
{
    if (mHeaderParsed)
    {
        return;
    }
    
    mHeaderParsed = YES;
    
    mFrom = [self valueForHeaderField:@"from"];
    mTo = [self valueForHeaderField:@"to"];
    mCC = [self valueForHeaderField:@"cc"];
    mSubject = [[self.edMessage subject] copy];
    mDate = [[self.edMessage date] copy];    
}

- (void)parseContent
{
    if (mContentParsed)
    {
        return;
    }
    
    mContentParsed = YES;
    
    if ([EDHTMLTextContentCoder canDecodeMessagePart:[self edMessage]])
    {
        EDHTMLTextContentCoder *htmlCoder = [[EDHTMLTextContentCoder alloc] initWithMessagePart:[self edMessage]];
        mBestPart = [MessagePart messagePartWithHtml:[[htmlCoder text] copy]];
        return;
    }
    
    if ([EDPlainTextContentCoder canDecodeMessagePart:[self edMessage]])
    {
        EDPlainTextContentCoder *textCoder = [[EDPlainTextContentCoder alloc] initWithMessagePart:[self edMessage]];
        mBestPart = [MessagePart messagePartWithText:[[textCoder text] copy]];
        return;
    }
    
    if ([EDCompositeContentCoder canDecodeMessagePart:[self edMessage]])
    {
        EDCompositeContentCoder *compositeCoder = [[EDCompositeContentCoder alloc] initWithMessagePart:[self edMessage]];
        
        NSArray *subparts = [compositeCoder subparts];
        
        for (NSUInteger i = 0; i < [subparts count]; i++)
        {
            EDMessagePart *edPart = [subparts objectAtIndex:i];
            if ([EDMultimediaContentCoder canDecodeMessagePart:edPart])
            {
                EDMultimediaContentCoder *fileCoder = [[EDMultimediaContentCoder alloc] initWithMessagePart:edPart];
                MessageAttachment *attachment = [[MessageAttachment alloc] initWithData:[[fileCoder data] copy] fileName:[[fileCoder filename] copy]];
                
                if (!mAttachments)
                {
                    mAttachments = [[NSMutableArray alloc] init];
                }
                
                [mAttachments addObject:attachment];
                continue;
            }
            
            if ([EDHTMLTextContentCoder canDecodeMessagePart:edPart])
            {
                EDHTMLTextContentCoder *htmlCoder = [[EDHTMLTextContentCoder alloc] initWithMessagePart:edPart];
                MessagePart *part = [MessagePart messagePartWithHtml:[[htmlCoder text] copy]];
                
                if (!mBestPart)
                {
                    mBestPart = part;
                }
                
                if (!mSubparts)
                {
                    mSubparts = [[NSMutableSet alloc] init];
                }
                
                [mSubparts addObject:part];
                continue;
            }
            
            if ([EDPlainTextContentCoder canDecodeMessagePart:edPart])
            {
                EDPlainTextContentCoder *textCoder = [[EDPlainTextContentCoder alloc] initWithMessagePart:edPart];
                MessagePart *part = [MessagePart messagePartWithText:[[textCoder text] copy]];
                
                if (!mSubparts)
                {
                    mSubparts = [[NSMutableSet alloc] init];
                }
                
                [mSubparts addObject:part];
                continue;
            }
        }
        
        if (!mBestPart)
        {
            if (mSubparts)
            {
                mBestPart = [mSubparts anyObject];
            }
        }
    }
}

- (NSString *)from
{
    if (mFrom)
    {
        return mFrom;
    }
    
    [self parseHeader];
    return mFrom;
}

- (NSString *)to
{
    if (mTo)
    {
        return mTo;
    }
    
    [self parseHeader];
    return mTo;
}

- (NSString *)subject
{
    if (mSubject)
    {
        return mSubject;
    }
    
    [self parseHeader];
    return mSubject;
}

- (NSCalendarDate *)date
{
    if (mDate)
    {
        return mDate;
    }
    
    [self parseHeader];
    return mDate;
}

- (NSString *)cc
{
    if (mCC)
    {
        return mCC;
    }
    
    [self parseHeader];
    return mCC;
}

- (NSSet *)subparts
{
    if (mSubparts)
    {
        return mSubparts;
    }
    
    [self parseContent];
    return mSubparts;
}

- (MessagePart *)bestPart
{
    if (mBestPart)
    {
        return mBestPart;
    }
    
    [self parseContent];
    return mBestPart;
}

- (NSArray *)attachments
{
    if (mAttachments)
    {
        return mAttachments;
    }
    
    [self parseContent];
    return mAttachments;
}

- (NSString *)transferText
{
    if (mTransferText)
    {
        return mTransferText;
    }
    
    mTransferText = [NSString stringWithData:[self transferData] encoding:NSASCIIStringEncoding];
    return mTransferText;
}

@end
