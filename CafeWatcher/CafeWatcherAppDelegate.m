//
//  CafeWatcherAppDelegate.m
//  CafeWatcher
//
//  Created by Tomohiko Koyama on 11/06/23.
//  Copyright 2011 Katamari Inc. All rights reserved.
//

#import "CafeWatcherAppDelegate.h"
#import "Watcher.h"
#import "Growl.framework/Headers/GrowlApplicationBridge.h"


@implementation CafeWatcherAppDelegate


@synthesize window;
@synthesize paths;
@synthesize table;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [GrowlApplicationBridge setGrowlDelegate:@""];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"watchers"];
    if (data) {
        NSArray *watchers = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [paths addObjects:watchers];
        for (Watcher *watcher in watchers) {
            [watcher watch];
        }
    }
}


//- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
//    return YES;
//}

- (void)save {
    NSArray *watchers = [paths content];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:watchers];
    [defaults setObject:data forKey:@"watchers"];
    [defaults synchronize];
}


- (IBAction)addFolder:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:YES];
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            Watcher *watcher = [[[Watcher alloc] initWithURL:url] autorelease];
            [watcher watch];
            [paths addObject:watcher];
        }
        [self save];
    }
}


- (IBAction)deleteFolder:(id)sender {
    [paths removeObjects:[paths selectedObjects]];
    [self save];
}


- (IBAction)browseNode:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setDelegate:self];
    browseNode_ = YES;
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
        [defaults setValue:[[panel URL] path] forKey:@"node"];
    }
    [panel setDelegate:nil];
}


- (IBAction)browseCoffee:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setDelegate:self];
    browseNode_ = NO;
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
        [defaults setValue:[[panel URL] path] forKey:@"coffee"];
    }
    [panel setDelegate:nil];
}


- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
    return CFURLHasDirectoryPath((CFURLRef)url) || [[url lastPathComponent] compare:browseNode_ ? @"node" : @"coffee"] == NSOrderedSame;
}


@end
