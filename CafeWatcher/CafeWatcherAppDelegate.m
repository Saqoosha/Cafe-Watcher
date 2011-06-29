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
#import "SCEvent.h"


@interface CafeWatcherAppDelegate(Private)
- (void)save;
- (void)watch;
- (void)doubleClicked:(id)hoge;
@end


@implementation CafeWatcherAppDelegate


@synthesize window;
@synthesize paths;
@synthesize table;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [GrowlApplicationBridge setGrowlDelegate:@""];
    
    events_ = [[SCEvents alloc] init];
    [events_ setDelegate:self];
    [events_ setNotificationLatency:0.5];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"watchers"];
    if (data) {
        NSArray *watchers = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [paths addObjects:watchers];
        [self watch];
    }
    
    [table setDoubleAction:@selector(doubleClicked:)];
}


- (void)doubleClicked:(id)sender {
    [self editFolder:sender];
}


- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event {
//    NSLog(@"pathWatche: %@, %@", pathWatcher, event);
    for (Watcher *watcher in [paths content]) {
        if ([[watcher path] compare:[event eventPath]] == NSOrderedSame) {
            [watcher compileModifiedFiles];
        }
    }
}


- (void)save {
    NSArray *watchers = [paths content];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:watchers];
    [defaults setObject:data forKey:@"watchers"];
    [defaults synchronize];
}


- (void)watch {
    [events_ flushEventStreamSync];
    [events_ stopWatchingPaths];
    
    if ([[paths content] count] > 0) {
        NSMutableArray *p = [[[NSMutableArray alloc] init] autorelease];
        for (Watcher *watcher in [paths content]) {
            [p addObject:[watcher path]];
        }
        [events_ startWatchingPaths:p];
        NSLog(@"started: %@", [events_ streamDescription]);
    }
}


- (IBAction)addFolder:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:YES];
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            [paths addObject:[[[Watcher alloc] initWithURL:url] autorelease]];
        }
        [self save];
        [self watch];
    }
}


- (IBAction)deleteFolder:(id)sender {
    [paths removeObjects:[paths selectedObjects]];
    [self save];
    [self watch];
}


- (IBAction)editFolder:(id)sender {
    NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
    NSString *editor = [defaults stringForKey:@"editor"];
    for (Watcher *watcher in [paths selectedObjects]) {
        [[NSWorkspace sharedWorkspace] openFile:[watcher path] withApplication:editor];
    }
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


- (IBAction)browseEditor:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"app"]];
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
        [defaults setValue:[[panel URL] path] forKey:@"editor"];
    }
}


- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
    return CFURLHasDirectoryPath((CFURLRef)url) || [[url lastPathComponent] compare:browseNode_ ? @"node" : @"coffee"] == NSOrderedSame;
}


@end
