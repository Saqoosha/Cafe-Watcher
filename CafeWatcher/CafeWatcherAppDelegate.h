//
//  CafeWatcherAppDelegate.h
//  CafeWatcher
//
//  Created by Tomohiko Koyama on 11/06/23.
//  Copyright 2011 Katamari Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindow.h"
#import "SCEvents.h"
#import "SCEventListenerProtocol.h"


@interface CafeWatcherAppDelegate : NSObject <NSApplicationDelegate, NSOpenSavePanelDelegate, SCEventListenerProtocol> {
@private
    MainWindow *window;
    NSArrayController *paths;
    NSTableView *table;

    SCEvents *events_;

    BOOL browseNode_;
}


@property (assign) IBOutlet MainWindow *window;
@property (assign) IBOutlet NSArrayController *paths;
@property (assign) IBOutlet NSTableView *table;


- (IBAction)addFolder:(id)sender;
- (IBAction)deleteFolder:(id)sender;
- (IBAction)browseNode:(id)sender;
- (IBAction)browseCoffee:(id)sender;


@end
