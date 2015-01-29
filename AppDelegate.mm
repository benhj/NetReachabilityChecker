//
//  AppDelegate.m
//  OSXWebsiteHealthChecker
//
//  Created by Ben Jones on 1/28/15.
//  Copyright (c) 2015 Ben Jones. All rights reserved.
//

#import "AppDelegate.h"
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
    
    [_menu addItemWithTitle:@"Refresh"
                     action:@selector(processRefresh:)
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
    
    // Every five minutes, check website reachability
    [self performSelectorInBackground:@selector(pollingRefresh:) withObject:nil];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void)frontAbout:(id)sender{
    
    [NSApp activateIgnoringOtherApps:YES];
    
    [NSApp orderFrontStandardAboutPanel:self];
}

- (void)doWebsiteCheck:(NSString*)address {
    if(address) {
        std::string cstring = [address UTF8String];
        SCNetworkReachabilityRef target;
        SCNetworkConnectionFlags flags = 0;
        Boolean ok;
        target = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), cstring.c_str());
        
        if(target) {
            SCNetworkReachabilityGetFlags(target, &flags);
            CFRelease(target);
        }
        
        ok = (flags & kSCNetworkReachabilityFlagsReachable);
        NSMenuItem *item;
        auto it(_webItems.find(cstring));
        
        Boolean oldEntry = NO;
        
        if(it != std::end(_webItems)) {
            oldEntry = YES;
            item = it->second;
        } else {
            item = [[NSMenuItem alloc] init];
            item.title = address;
            if(_webItems.empty()) {
                [_menu addItem:[NSMenuItem separatorItem]]; // A thin grey line
            }
            _webItems.insert(std::make_pair(cstring, item));
            [_menu addItem:item];
        }
        
        if(ok) {
            item.image = [ NSImage imageNamed:@"green"];
            if(oldEntry == NO) {
                [self showGoodNotification:address];
            }
        } else {
            item.image = [ NSImage imageNamed:@"red"];
            
            // pop up a notification saying website has gone down
            if(oldEntry == YES) {
                [self showGoneDownNotification:address];
            }
            
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
    NSLog(@"notification: %@", notification);
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

- (void)pollingRefresh:(id)sender {
    while(1) {
        for(auto const & it : _webItems) {
            [self doWebsiteCheck:[NSString stringWithCString:it.first.c_str()
                                                    encoding:[NSString defaultCStringEncoding]]];
        }
        sleep(300);
    }
}

- (void)processDialog:(id)sender {
    NSString* webAddress = [self input:@"Web address to check status of:"
                          defaultValue:@"www.google.com"];
    [self doWebsiteCheck:webAddress];
}

- (void)processRefresh:(id)sender {
    for(auto const & it : _webItems) {
        [self doWebsiteCheck:[NSString stringWithCString:it.first.c_str()
                                                encoding:[NSString defaultCStringEncoding]]];
    }
}

- (void)processExit:(id)sender {
    [NSApp terminate: nil];
}

@end
