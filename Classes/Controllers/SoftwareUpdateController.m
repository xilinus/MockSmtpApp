//
//  SoftwareUpdateController.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 06/01/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import "SoftwareUpdateController.h"
#import "JSON.h"

@interface NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
@end

@implementation NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL
{
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
    NSRange range = NSMakeRange(0, [attrString length]);
    
    [attrString beginEditing];
    [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
    
    [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
    
    NSFont *font = [NSFont systemFontOfSize:11.0f];
    [attrString addAttribute:NSFontAttributeName value:font range:range];
    
    [attrString addAttribute:
     NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
    
    [attrString endEditing];
    
    return [attrString autorelease];
}
@end

@implementation SoftwareUpdateController

@synthesize isChecking = mIsChecking;
@synthesize isChecked = mIsChecked;
@synthesize isNewVersion = mIsNewVersion;

@synthesize shortStatusString = mShortStatusString;
@synthesize statusString = mStatusString;
@synthesize url = mUrl;

@synthesize webView = mWebView;
@synthesize window = mWindow;

@synthesize defaultsController = mDefaultsController;

- (void)checkForUpdates
{
    if (self.isChecking || self.isChecked)
    {
        return;
    }
    
    [mWebView setHidden:YES];
    
	NSString *urlString = @"http://mocksmtpapp.com/update?from=";
	NSString *bundleVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString *urlWithVersionString = [urlString stringByAppendingString:bundleVersionString];
	
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:urlWithVersionString]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection)
    {
        self.isChecking = YES;
        mReceivedData=[[NSMutableData alloc] init];
        self.shortStatusString = @"Checking for Updates";
        self.statusString = @"Looking for a newer version of MockSmtp...";
    }
    else
    {
    }
}

- (void)awakeFromNib
{
    mAutoUpdate = [[mDefaultsController values] valueForKey:@"autoUpdate"];
    [mDefaultsController addObserver:self forKeyPath:@"values.autoUpdate" options:NSKeyValueObservingOptionNew context:nil];
    
    if ([mAutoUpdate boolValue])
    {
        mTimer = [NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        if (!mWindowShowing) [self checkForUpdates];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    BOOL autoUpdate = [[[mDefaultsController values] valueForKey:@"autoUpdate"] boolValue];
    BOOL savedAutoUpdate = [[[mDefaultsController defaults] stringForKey:@"autoUpdate"] intValue];
    
    if (autoUpdate == savedAutoUpdate && [mAutoUpdate boolValue] != savedAutoUpdate)
    {
        mAutoUpdate = [NSNumber numberWithBool:savedAutoUpdate];
        
        if (savedAutoUpdate)
        {
            mTimer = [NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
            if (!mWindowShowing) [self checkForUpdates];
        }
        else
        {
            [mTimer invalidate];
            mTimer = nil;
        }
    }
}

- (void)timerTick:(NSTimer *)timer
{
    if (!mWindowShowing)
    {
        NSLog(@"update");
        [self checkForUpdates];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [mReceivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mReceivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.isChecking = NO;
    self.isChecked = YES;
    self.isNewVersion = NO;
    
    self.shortStatusString = @"Connection failed";
    self.statusString = [NSString  stringWithFormat:@"Error - %@.", [error localizedDescription]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *jsonString = [[NSString alloc] initWithData:mReceivedData encoding:NSUTF8StringEncoding];
    
    SBJSON *parser = [[SBJSON alloc] init];
    
    NSArray *releases = [parser objectWithString:jsonString];
    
    NSDictionary *latestRelease = [releases objectAtIndex:0];
    
    
    NSString *version = [latestRelease objectForKey:@"version"];
    NSString *title = [latestRelease objectForKey:@"title"];
    NSString *description = [latestRelease objectForKey:@"description"];
    NSString *url = [latestRelease objectForKey:@"url"];
    
    NSInteger releaseVersion = [version intValue];
    NSString *bundleVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSInteger bundleVersion = [bundleVersionString intValue];
    
    if (releaseVersion > bundleVersion)
    {
        self.isNewVersion = YES;
        self.shortStatusString = @"New Version Available";
        self.statusString = [NSString stringWithFormat:@"MockSmtp %@ \"%@\" available for download.", version, title];
        NSURL *theUrl = [NSURL URLWithString:url];
        self.url = [NSAttributedString hyperlinkFromString:[NSString stringWithFormat:@"MockSmtp %@", version] withURL:theUrl];
        
        [mWebView setHidden:NO];
        [[mWebView mainFrame] loadHTMLString:description baseURL:nil];
        
        if (!mWindowShowing)
        {
            [mWindow makeKeyAndOrderFront:self];
        }
    }
    else
    {
        self.isNewVersion = NO;
        self.shortStatusString = @"No Updates Found";
        self.statusString = @"There are no updates available.";
    }
    
    self.isChecking = NO;
    self.isChecked = YES;
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    [mWebView setShouldCloseWithWindow:NO];
    [self checkForUpdates];
    mWindowShowing = YES;
}

- (void)windowWillClose:(NSNotification *)notification
{
    self.isChecking = NO;
    self.isChecked = NO;
    self.isNewVersion = NO;
    mWindowShowing = NO;
}

@end
