//
//  AppDelegate.m
//  NetReachabilityChecker (Formerly OSXWebsiteHealthChecker)
//
//  Created by Ben Jones on 1/28/15.
//  Copyright (c) 2015 Ben Jones. All rights reserved.
//

#import "AppDelegate.h"
#import "CallbackInfo.h"
#import <SystemConfiguration/SystemConfiguration.h>
#include <string>
#include <map>

@implementation AppDelegate

// for reachability checking, store necessary objects in a map
// of CambackInfo objects.
std::map<std::string, CallbackInfo*> infos;

NSMenuItem *finalSeperatorLine = [NSMenuItem separatorItem];

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
    _statusItem                = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.title          = @"";
    _statusItem.toolTip        = @"Website health displayer";
    _statusItem.image          = [NSImage imageNamed:@"bwCross"];
    _statusItem.alternateImage = [NSImage imageNamed:@"bwCross"];
    _statusItem.highlightMode  = YES;
    
    // Menu stuff
    _menu = [[NSMenu alloc] init];
    
    // For popping up a dialog of what website user wants checked
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
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void)frontAbout:(id)sender{
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:self];
}

-(void)removeItemSelector:(id)sender{
    
    // search for the address, remove associated website from menu and from map
    NSString* address = [sender representedObject];
    auto it(infos.find([address UTF8String]));
    if(it != std::end(infos)) {
        auto info = it->second;
        auto item = [info getMenuItem];
        
        // remove from menu
        [_menu removeItem:item];
        
        // remove from map
        infos.erase(it);
        
        // remove the final seperator line if map is now empty
        if(infos.empty()) {
            [_menu removeItem:finalSeperatorLine];
        }
    }
}

- (void)setupReachability:(NSString*)address {
    if(address) {
        
        SCNetworkReachabilityRef target;
        SCNetworkConnectionFlags flags = 0;
        target = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [address UTF8String]);
        
        if(target) {
            
            // aesthetics
            if(infos.empty()) {
                [_menu addItem:finalSeperatorLine]; // A thin grey line
            }
            
            // Add a menu item representing the 'website being checked'
            NSMenuItem *item;
            item       = [[NSMenuItem alloc] init];
            item.title = address;
            [_menu addItem:item];
            
            // Add a sub menu with option to remove the website
            NSMenu *subMenu = [[NSMenu alloc] init];
            NSMenuItem *subItem = [[NSMenuItem alloc] initWithTitle:@"Remove"
                                                             action:@selector(removeItemSelector:)
                                                      keyEquivalent:@""];
            
            // Add the url address to the sub menu item so that it can be retrieved in selector
            [subItem setRepresentedObject:address];
            [subMenu addItem:subItem];
            [item setSubmenu:subMenu];
            
            // Store information related to address in a covenient object
            CallbackInfo* cbinfo = [[CallbackInfo alloc] init];
            [cbinfo setAddress:address];
            [cbinfo setApp:self];
            [cbinfo setAssociatedItem:item];
            infos.insert(std::make_pair([address UTF8String], cbinfo));
            
            // Set up network reachability on address
            SCNetworkReachabilityGetFlags(target, &flags);
            SCNetworkReachabilityContext context = {0, NULL, NULL, NULL, NULL};
            context.info = (void*)CFBridgingRetain(address);
            
            // callback triggered whenever reachability changes
            if (SCNetworkReachabilitySetCallback(target, callback, &context)) {
                if (SCNetworkReachabilityScheduleWithRunLoop(target, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode) ) {
                    NSLog(@"create and config reachability sucess") ;
                }
            }
        } else if (target != NULL) {
            CFRelease(target);
        }
    }
}

// called every time reachability changes
void callback(SCNetworkReachabilityRef target,
              SCNetworkConnectionFlags flags,
              void *info)
{
    auto address = (NSString*)CFBridgingRelease(info);
    auto it(infos.find([address UTF8String]));
    if(it != std::end(infos)) {
        auto cbinfo = (infos.find([address UTF8String]))->second;
        
        // check that a connection isn't required. If a connection isn't required,
        // we're probably connected;
        Boolean ok = !(flags & kSCNetworkReachabilityFlagsConnectionRequired);
        if(ok) {
            // now check that given the connection, the address can be reached
            ok = flags & kSCNetworkReachabilityFlagsReachable;
        }
        auto item = [cbinfo getMenuItem];
        auto app  = [cbinfo getApp];
        if(ok) {
            item.image = [ NSImage imageNamed:@"greenTick"];
            [app showGoodNotification:address];
        } else {
            item.image = [ NSImage imageNamed:@"redCross"];
            [app showGoneDownNotification:address];
        }
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
