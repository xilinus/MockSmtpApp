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
#import "Message.h"

@implementation WebViewController

@synthesize webView = _webView;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		//[[[self.webView mainFrame] frameView] setAllowsScrolling:NO];
	}
	
	return self;
}

- (void)setContent:(id)content
{
    [super setContent:content];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *resourcesPath = [mainBundle resourcePath];
    NSURL *resourcesUrl = [NSURL fileURLWithPath:resourcesPath];
    
	NSString *html = (NSString *)content;
    [[_webView mainFrame] loadHTMLString:html baseURL:resourcesUrl];
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

- (void)webView:(WebView *)webView didFinishLoadForFrame:(WebFrame *)webFrame
{
	/*if([webFrame isEqual:[webView mainFrame]])
    {
        //get the rect for the rendered frame
        NSRect webFrameRect = [[[webFrame frameView] documentView] frame];
        //get the rect of the current webview
        NSRect webViewRect = [webView frame];
		
        //calculate the new frame
        NSRect newWebViewRect = NSMakeRect(webViewRect.origin.x, 
                                           0, //webViewRect.origin.y - (NSHeight(webFrameRect) - NSHeight(webViewRect)), 
                                           NSWidth(webViewRect), 
                                           NSHeight(webFrameRect));
        //set the frame
        [webView setFrame:newWebViewRect];
		
        NSLog(@"The dimensions of the page are: %@", NSStringFromRect(webFrameRect));
    }*/
}

@end
