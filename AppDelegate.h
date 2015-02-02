//
//  AppDelegate.h
//  OSXWebsiteHealthChecker
//
//  Created by Ben Jones on 1/28/15.
//  Copyright (c) 2015 Ben Jones. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
    NSStatusItem* _statusItem;
    NSMenu* _menu;
}

- (NSString *)input: (NSString *)prompt
       defaultValue: (NSString *)defaultValue;

- (void)frontAbout:(id)sender;
- (void)processDialog:(id)sender;
- (void)processExit:(id)sender;
- (void)setupReachability:(NSString*)address;

-(void)showGenericNotification:(NSString*) title
                   withMessage:(NSString*) message;

-(void)showGoneDownNotification:(NSString*) site;
-(void)showGoodNotification:(NSString*) site;

// for deleting a previouslay added item
-(void)removeItemSelector:(id)sender;


@end

