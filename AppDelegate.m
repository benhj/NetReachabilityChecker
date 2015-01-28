//
//  AppDelegate.m
//  OSXWebsiteHealthChecker
//
//  Created by Ben Jones on 1/28/15.
//  Copyright (c) 2015 Ben Jones. All rights reserved.
//

#import "AppDelegate.h"
#import <SystemConfiguration/SystemConfiguration.h>


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
        return _webAddress ? _webAddress : nil;
    } else {
        return nil;
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Set up the icon that is displayed in the status bar
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.title = @"";
    _statusItem.toolTip = @"Website health displayer";
    _statusItem.image = [NSImage imageNamed:@"blue"];
    _statusItem.alternateImage = [NSImage imageNamed:@"blue"];
    _statusItem.highlightMode = YES;
    
    // Menu stuff
    NSMenu *menu = [[NSMenu alloc] init];
    
    // For popping up a dialog of where user want email notifications
    // to be delivered
    [menu addItemWithTitle:@"Website to check health of.."
                    action:@selector(processDialog:)
             keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]]; // A thin grey line
    
    [menu addItemWithTitle:@"Refresh"
                    action:@selector(processRefresh:)
             keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]]; // A thin grey line
    
    // Add a simple 'about' item
    [menu addItemWithTitle:@"About"
                    action:@selector(orderFrontStandardAboutPanel:)
             keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]]; // A thin grey line
    
    // Add an exit item to exit program
    [menu addItemWithTitle:@"Exit"
                    action:@selector(processExit:)
             keyEquivalent:@""];
    _statusItem.menu = menu;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)doWebsiteCheck {
    if(_webAddress) {
        NSLog(_webAddress, nil);
        SCNetworkReachabilityRef target;
        SCNetworkConnectionFlags flags = 0;
        Boolean ok;
        target = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [_webAddress UTF8String]);
        
        if(target) {
            SCNetworkReachabilityGetFlags(target, &flags);
            CFRelease(target);
        }
        
        ok = (flags & kSCNetworkReachabilityFlagsReachable);
        if(ok) {
            _statusItem.image = [NSImage imageNamed:@"green"];
            _statusItem.alternateImage = [NSImage imageNamed:@"green"];
        } else {
            _statusItem.image = [NSImage imageNamed:@"red"];
            _statusItem.alternateImage = [NSImage imageNamed:@"red"];
        }
    }
}

- (void)processDialog:(id)sender {
    _webAddress = [self input:@"Enter website address to check health of"
                 defaultValue:_webAddress ? _webAddress : @"www.google.com"];
    _statusItem.toolTip = _webAddress;
    [self doWebsiteCheck];
}

- (void)processRefresh:(id)sender {
    [self doWebsiteCheck];
}

- (void)processExit:(id)sender {
    [NSApp terminate: nil];
}

@end
