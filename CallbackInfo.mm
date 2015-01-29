//
//  CallbackInfo.m
//  OSXWebsiteHealthChecker
//
//  Created by Ben Jones on 1/29/15.
//  Copyright (c) 2015 Ben Jones. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CallbackInfo.h"
#import "AppDelegate.h"

@implementation CallbackInfo

- (void)setAddress:(NSString*)ws {
    address = ws;
}
- (NSString*)getAddress {
    return address;
}
- (void)setApp:(AppDelegate*)del {
    app = del;
}
- (AppDelegate*)getApp {
    return app;
}
- (void)setAssociatedItem:(NSMenuItem*)item {
    associatedItem = item;
}
- (NSMenuItem*)getMenuItem {
    return associatedItem;
}

@end
