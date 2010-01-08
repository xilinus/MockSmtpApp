//
//  main.m
//  SmtpTestServer
//
//  Created by Oleg Shnitko on 11/11/2009.
//  Copyright Natural Devices, Inc. 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    lcl_configure_by_name("MockSmtp/*", lcl_vInfo);
    lcl_configure_by_name("MockSmtp/*", lcl_vDebug);
    
    lcl_log(lcl_cMain, lcl_vInfo, @"Application launched.");
    
    return NSApplicationMain(argc, (const char **) argv);
}
