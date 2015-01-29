//
//  CallbackInfo.h
//  OSXWebsiteHealthChecker
//
//  Used to store information pertaining to web-check callback in AppDelegate
//
//  Created by Ben Jones on 1/29/15.
//  Copyright (c) 2015 Ben Jones. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDelegate;
@class NSMenuItem;
@class NSString;

@interface CallbackInfo : NSObject {
    AppDelegate *app;
    NSString *address;
    NSMenuItem *associatedItem;
}

/// The web address
- (void)setAddress:(NSString*)ws;
- (NSString*)getAddress;

/// The app delegate
- (void)setApp:(AppDelegate*)del;
- (AppDelegate*)getApp;

/// The manu item associated with the address
- (void)setAssociatedItem:(NSMenuItem*)item;
- (NSMenuItem*)getMenuItem;

@end
