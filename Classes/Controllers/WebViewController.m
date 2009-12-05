//
//  WebViewController.m
//  TestSMTP
//
//  Created by Oleg Shnitko on 07/11/2009.
//  olegshnitko@gmail.com
//  Copyright © 2009 7touch Group, Inc.
//  All rights reserved.
//

#import "WebViewController.h"


@implementation WebViewController

@synthesize webView = _webView;

- (void)setContent:(id)content
{
    [super setContent:content];
    NSString *body = [content valueForKey:@"body"];
    [content setValue:[NSNumber numberWithBool:YES] forKey:@"read"];
    [[_webView mainFrame] loadHTMLString:body baseURL:nil];
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request
          frame:(WebFrame *)frame
decisionListener:(id <WebPolicyDecisionListener>)listener
{
    NSInteger type = [[actionInformation objectForKey:WebActionNavigationTypeKey] intValue];
    
    if (type == WebNavigationTypeLinkClicked)
    {
        [listener ignore];
        [[NSWorkspace sharedWorkspace] openURL:[request URL]];
    }
    else
    {
        [listener use];
    }
}

@end
