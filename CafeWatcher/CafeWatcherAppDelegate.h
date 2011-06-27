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

@interface CafeWatcherAppDelegate : NSObject <NSApplicationDelegate, NSOpenSavePanelDelegate> {
@private
    MainWindow *window;
    NSArrayController *paths;
    PathTableView *table;
    BOOL browseNode_;
}

@property (assign) IBOutlet MainWindow *window;
@property (assign) IBOutlet NSArrayController *paths;
@property (assign) IBOutlet PathTableView *table;

- (IBAction)addFolder:(id)sender;
- (IBAction)deleteFolder:(id)sender;
- (IBAction)browseNode:(id)sender;
- (IBAction)browseCoffee:(id)sender;

@end
