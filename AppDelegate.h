//
//  AppDelegate.h
//  OSXWebsiteHealthChecker
//
//  Created by Ben Jones on 1/28/15.
//  Copyright (c) 2015 Ben Jones. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <vector>
#include <map>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
    NSStatusItem* _statusItem;
    std::map<std::string, NSMenuItem*> _webItems;
    NSMenu* _menu;
}


- (NSString *)input: (NSString *)prompt
       defaultValue: (NSString *)defaultValue;

- (void)frontAbout:(id)sender;
- (void)processDialog:(id)sender;
- (void)processExit:(id)sender;
- (void)processRefresh:(id)sender;
- (void)doWebsiteCheck:(NSString*)address;

// for checking site status every five minutes
- (void)pollingRefresh:(id)sender;

-(void)showGenericNotification:(NSString*) title
                   withMessage:(NSString*) message;

-(void)showGoneDownNotification:(NSString*) site;
-(void)showGoodNotification:(NSString*) site;

@end

