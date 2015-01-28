//
//  AppDelegate.h
//  OSXWebsiteHealthChecker
//
//  Created by Ben Jones on 1/28/15.
//  Copyright (c) 2015 Ben Jones. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSStatusItem* _statusItem;
    NSString* _webAddress;
}


- (NSString *)input: (NSString *)prompt
       defaultValue: (NSString *)defaultValue;

- (void)processDialog:(id)sender;
- (void)processExit:(id)sender;
- (void)processRefresh:(id)sender;
- (void)doWebsiteCheck;

@end

