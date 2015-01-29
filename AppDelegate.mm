//
//  AppDelegate.m
//  OSXWebsiteHealthChecker
//
//  Created by Ben Jones on 1/28/15.
//  Copyright (c) 2015 Ben Jones. All rights reserved.
//

#import "AppDelegate.h"
#import "CallbackInfo.h"
#import <SystemConfiguration/SystemConfiguration.h>
#include <string>

@implementation AppDelegate

- (NSString *)input: (NSString *)prompt
       defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        return nil;
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Set up the icon that is displayed in the status bar
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.title = @"";
    _statusItem.toolTip = @"Website health displayer";
    _statusItem.image = [NSImage imageNamed:@"greencross"];
    _statusItem.alternateImage = [NSImage imageNamed:@"greencross"];
    _statusItem.highlightMode = YES;
    
    // Menu stuff
    _menu = [[NSMenu alloc] init];
    
    // For popping up a dialog of where user want email notifications
    // to be delivered
    [_menu addItemWithTitle:@"Add website..."
                     action:@selector(processDialog:)
              keyEquivalent:@""];
    
    [_menu addItem:[NSMenuItem separatorItem]]; // A thin grey line
    
    // Add a simple 'about' item
    [_menu addItemWithTitle:@"About"
                     action:@selector(frontAbout:)
              keyEquivalent:@""];
    
    // Add an exit item to exit program
    [_menu addItemWithTitle:@"Exit"
                     action:@selector(processExit:)
              keyEquivalent:@""];
    _statusItem.menu = _menu;
    [_menu addItem:[NSMenuItem separatorItem]]; // A thin grey line
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void)frontAbout:(id)sender{
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:self];
}

- (void)setupReachability:(NSString*)address {
    if(address) {

        SCNetworkReachabilityRef target;
        SCNetworkConnectionFlags flags = 0;
        target = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [address UTF8String]);
        
        if(target) {
            
            NSMenuItem *item;
            item = [[NSMenuItem alloc] init];
            item.title = address;
            [_menu addItem:item];

            CallbackInfo* cbinfo = [[CallbackInfo alloc] init];
            [cbinfo setAddress:address];
            [cbinfo setApp:self];
            [cbinfo setAssociatedItem:item];
            SCNetworkReachabilityGetFlags(target, &flags);
            SCNetworkReachabilityContext context = {0, NULL, NULL, NULL, NULL};
            context.info = (void*)CFBridgingRetain(cbinfo);
            
            // callback triggered whenever reachability has changed
            if (SCNetworkReachabilitySetCallback(target, callback, &context)) {
                if (SCNetworkReachabilityScheduleWithRunLoop(target, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode) ) {
                    NSLog(@"create and config reachability sucess") ;
                }
            }
        }
    }
}

// called every time reachability changes
void callback(SCNetworkReachabilityRef target,
              SCNetworkConnectionFlags flags,
              void *info)
{
    auto cbinfo = (CallbackInfo*)CFBridgingRelease(info);
    Boolean ok = (flags & kSCNetworkReachabilityFlagsReachable);
    auto address = [cbinfo getAddress];
    auto item = [cbinfo getMenuItem];
    auto app = [cbinfo getApp];
    if(ok) {
        item.image = [ NSImage imageNamed:@"green"];
        [app showGoodNotification:address];
    } else {
        item.image = [ NSImage imageNamed:@"red"];
        [app showGoneDownNotification:address];
    }
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

-(void)showGenericNotification:(NSString*) title
                   withMessage:(NSString*) message {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title               = title;
    notification.informativeText     = message;
    notification.soundName           = NSUserNotificationDefaultSoundName;
    notification.actionButtonTitle   = @"None";
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    center.delegate                  = self;
    [center scheduleNotification:notification];
}

-(void)showGoneDownNotification:(NSString*) site {
    
    NSMutableString* message = [[NSMutableString alloc] init];
    [message appendString:@"Website "];
    [message appendString:site];
    [message appendString:@" appears down."];
    [self showGenericNotification:@"Appears down"
                      withMessage:message];

}

-(void)showGoodNotification:(NSString*) site {
    NSMutableString* message = [[NSMutableString alloc] init];
    [message appendString:@"Website "];
    [message appendString:site];
    [message appendString:@" looks good."];
    [self showGenericNotification:@"Looks good"
                      withMessage:message];
    
}

- (void)processDialog:(id)sender {
    NSString* webAddress = [self input:@"Web address to check status of:"
                          defaultValue:@"www.google.com"];
    [self setupReachability:webAddress];
}

- (void)processExit:(id)sender {
    [NSApp terminate: nil];
}

@end
