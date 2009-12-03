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
    [[_webView mainFrame] loadHTMLString:content baseURL:nil];
}

@end
