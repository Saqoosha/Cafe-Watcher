//
//  CafeWatcherAppDelegate.h
//  CafeWatcher
//
//  Created by Tomohiko Koyama on 11/06/23.
//  Copyright 2011 Katamari Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindow.h"
#import "PathTableView.h"

@interface CafeWatcherAppDelegate : NSObject <NSApplicationDelegate> {
@private
    MainWindow *window;
    NSArrayController *paths;
    PathTableView *table;
}

@property (assign) IBOutlet MainWindow *window;
@property (assign) IBOutlet NSArrayController *paths;
@property (assign) IBOutlet PathTableView *table;

- (IBAction)addFolder:(id)sender;

@end
