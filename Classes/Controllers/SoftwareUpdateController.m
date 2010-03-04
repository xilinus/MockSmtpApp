//
//  SoftwareUpdateController.m
//  MockSmtp
//
//  Created by Oleg Shnitko on 06/01/2010.
//  Copyright 2010 Natural Devices, Inc.. All rights reserved.
//

#import "SoftwareUpdateController.h"
#import "JSON.h"
#import "NSFileManager+Extensions.h"

#define UPDATES_DIR @"~/.mocksmtp/tmp/updates"
#define UPDATES_FILE @"~/.mocksmtp/tmp/updates/latest.zip"
#define UPDATES_APP @"~/.mocksmtp/tmp/updates/MockSmtp.app"
#define UPDATES_APP_OLD @"~/.mocksmtp/tmp/updates/MockSmtp.app.old"

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
@synthesize isInstalling = mIsInstalling;
@synthesize isProcessing = mIsProcessing;
@synthesize isChecked = mIsChecked;
@synthesize isInstalled = mIsInstalled;
@synthesize isNewVersion = mIsNewVersion;

@synthesize shortStatusString = mShortStatusString;
@synthesize statusString = mStatusString;
@synthesize url = mUrl;

@synthesize webView = mWebView;
@synthesize window = mWindow;

@synthesize defaultsController = mDefaultsController;

+ (void)completeUpdateIfNeeded
{
    NSString *updateApp = [UPDATES_APP stringByStandardizingPath];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:updateApp])
    {
        return;
    }
    
    NSBundle *updateBundle = [NSBundle bundleWithPath:updateApp];
    NSString *updateBundleVersionString = [updateBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSInteger updateVersion = [updateBundleVersionString intValue];
    NSString *updatePath = [updateBundle bundlePath];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *mainBundleVersionString = [mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSInteger mainVersion = [mainBundleVersionString intValue];
    NSString *mainPath = [mainBundle bundlePath];
    
    if (updateVersion <= mainVersion)
    {
        return;
    }
    
    NSString *oldPath = [UPDATES_APP_OLD stringByStandardizingPath];
    
    NSApplication *app = [NSApplication sharedApplication];
    NSError *error = nil;
    
    if ([manager fileExistsAtPath:oldPath])
    {
        error = nil;
        if (![manager removeItemAtPath:oldPath error:&error])
        {
            [app presentError:error];
        }
    }
    
    error = nil;
    if (![manager moveItemAtPath:mainPath toPath:oldPath error:&error])
    {
        [app presentError:error];
    }
    
    error = nil;
    if (![manager copyItemAtPath:updatePath toPath:mainPath error:&error])
    {
        [app presentError:error];
    }
}

- (void)checkForUpdates
{
    if (self.isChecking || self.isChecked)
    {
        return;
    }
    
    NSString *updateApp = [UPDATES_APP stringByStandardizingPath];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:updateApp])
    {
        NSBundle *updateBundle = [NSBundle bundleWithPath:updateApp];
        NSString *bundleVersionString = [updateBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
        mInstalledVersion = [bundleVersionString intValue];
        self.isInstalled = YES;
        self.isNewVersion = NO;
    }
    
    [mWebView setHidden:YES];
    
	NSString *urlString = @"http://mocksmtpapp.com/update?from=";
	NSString *bundleVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString *urlWithVersionString = [urlString stringByAppendingString:bundleVersionString];
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlWithVersionString]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    
    mUpdateConnection = nil;
    mUpdateConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (mUpdateConnection)
    {
        self.isChecking = YES;
        self.isProcessing = YES;
        mReceivedData=[[NSMutableData alloc] init];
        self.shortStatusString = @"Checking for Updates";
        self.statusString = @"Looking for a newer version of MockSmtp...";
    }
    else
    {
        self.shortStatusString = @"Connection error";
        self.statusString = @"Can not create connection";
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

- (void)updateConnection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.isChecking = NO;
    self.isChecked = YES;
    self.isNewVersion = NO;
    
    mUpdateConnection = nil;
}

- (void)downloadConnection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.isInstalling = NO;
    self.isInstalled = NO;
    
    mDownloadConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (connection == mUpdateConnection)
    {
        [self updateConnection:connection didFailWithError:error];
    }
    else if (connection == mDownloadConnection)
    {
        [self downloadConnection:connection didFailWithError:error];
    }
    
    self.isProcessing = NO;

    self.shortStatusString = @"Connection failed";
    self.statusString = [NSString  stringWithFormat:@"Error - %@.", [error localizedDescription]];
}

- (void)updateConnectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *jsonString = [[NSString alloc] initWithData:mReceivedData encoding:NSUTF8StringEncoding];
    
    SBJSON *parser = [[SBJSON alloc] init];
    
    NSArray *releases = [parser objectWithString:jsonString];
    
    NSDictionary *latestRelease = [releases objectAtIndex:0];
    
    
    NSString *version = [latestRelease objectForKey:@"version"];
    NSString *versionString = [latestRelease objectForKey:@"version_string"];
    NSString *title = [latestRelease objectForKey:@"title"];
    NSString *description = [latestRelease objectForKey:@"description"];
    NSString *url = [latestRelease objectForKey:@"url"];
    
    NSInteger releaseVersion = [version intValue];
    NSString *bundleVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSInteger bundleVersion = [bundleVersionString intValue];
    
    if (releaseVersion > bundleVersion && releaseVersion > mInstalledVersion)
    {
        self.isNewVersion = YES;
        self.isInstalled = NO;
        self.shortStatusString = @"New Version Available";
        self.statusString = [NSString stringWithFormat:@"MockSmtp %@ \"%@\" available for download.", versionString, title];
        mDownloadUrl = [NSURL URLWithString:url];
        self.url = [NSAttributedString hyperlinkFromString:[NSString stringWithFormat:@"MockSmtp %@", versionString] withURL:mDownloadUrl];
        
        [mWebView setHidden:NO];
        [[mWebView mainFrame] loadHTMLString:description baseURL:nil];
        
        if (!mWindowShowing)
        {
            [mWindow makeKeyAndOrderFront:self];
        }
    }
    else
    {
        if (mInstalledVersion > bundleVersion)
        {
            self.shortStatusString = @"New Version Downloaded";
            self.statusString = @"You need to restart application to finish update process";
            self.isNewVersion = YES;
            
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
            self.isInstalled = YES;
            self.shortStatusString = @"No Updates Found";
            self.statusString = @"There are no updates available.";
        }
    }
    
    self.isChecking = NO;
    self.isChecked = YES;
    
    mUpdateConnection = nil;
}

- (void)downloadConnectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *updatesDir = [UPDATES_DIR stringByStandardizingPath];
    NSString *updateFile = [UPDATES_FILE stringByStandardizingPath];
    NSString *updateApp = [UPDATES_APP stringByStandardizingPath];
    
    NSError *error = nil;
    if (![NSFileManager createDirectoryAtPathIfNotExists:updatesDir error:&error])
    {
        self.shortStatusString = @"Update failed";
        self.statusString = [NSString  stringWithFormat:@"Error - %@.", [error localizedDescription]];
        self.isInstalling = NO;
        self.isInstalled = NO;
        return;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:updateFile])
    {
        error = nil;
        if (![manager removeItemAtPath:updateFile error:&error])
        {
            self.shortStatusString = @"Update failed";
            self.statusString = [NSString  stringWithFormat:@"Error - %@.", [error localizedDescription]];
            self.isInstalling = NO;
            self.isInstalled = NO;
            return;
        }
    }
    
    error = nil;
    if (![mReceivedData writeToFile:updateFile options:NSAtomicWrite error:&error])
    {
        self.shortStatusString = @"Update failed";
        self.statusString = [NSString  stringWithFormat:@"Error - %@.", [error localizedDescription]];
        self.isInstalling = NO;
        self.isInstalled = NO;
        return;
    }
    
    if ([manager fileExistsAtPath:updateApp])
    {
        error = nil;
        if (![manager removeItemAtPath:updateApp error:&error])
        {
            self.shortStatusString = @"Update failed";
            self.statusString = [NSString  stringWithFormat:@"Error - %@.", [error localizedDescription]];
            self.isInstalling = NO;
            self.isInstalled = NO;
            return;
        }
    }
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/unzip"];
    [task setArguments:[NSArray arrayWithObjects:@"-d", updatesDir, updateFile,nil]];
    
    [task launch];
    [task waitUntilExit];
    NSInteger status = [task terminationStatus];
    if (status)
    {
        self.shortStatusString = @"Update failed";
        self.statusString = @"Error while unpacking archive";
        self.isInstalling = NO;
        self.isInstalled = NO;
        return;
    }
    
    self.shortStatusString = @"New Version Downloaded";
    self.statusString = @"You need to restart application to finish update process";
    self.isInstalling = NO;
    self.isInstalled = YES;
    mDownloadConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == mUpdateConnection)
    {
        [self updateConnectionDidFinishLoading:connection];
    }
    else if (connection == mDownloadConnection)
    {
        [self downloadConnectionDidFinishLoading:connection];
    }
    
    self.isProcessing = NO;
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    [mWebView setShouldCloseWithWindow:NO];
    [self checkForUpdates];
    mWindowShowing = YES;
}

- (void)windowWillClose:(NSNotification *)notification
{
    [mUpdateConnection cancel];
    [mDownloadConnection cancel];
    mUpdateConnection = nil;
    mDownloadConnection = nil;
    
    self.isChecking = NO;
    self.isInstalling = NO;
    self.isProcessing = NO;
    self.isChecked = NO;
    self.isInstalled = NO;
    self.isNewVersion = NO;
    mWindowShowing = NO;
}

- (IBAction)install:(id)sender
{
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:mDownloadUrl
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:60.0];
    
    mDownloadConnection = nil;
    mDownloadConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (mDownloadConnection)
    {
        self.isInstalling = YES;
        self.isProcessing = YES;
        mReceivedData=[[NSMutableData alloc] init];
        self.shortStatusString = @"Updating to a new version";
        self.statusString = @"Downloading...";
    }
    else
    {
        self.shortStatusString = @"Connection error";
        self.statusString = @"Can not create connection";
    }    
}

- (IBAction)cancel:(id)sender
{
    [mWindow performClose:sender];
}

@end
