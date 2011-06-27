//
//  Watcher.m
//  CafeWatcher
//
//  Created by hiko on 11/06/24.
//  Copyright 2011 Katamari Inc. All rights reserved.
//

#import "Watcher.h"
#import "LogWindow.h"
#import "Growl.framework/Headers/GrowlApplicationBridge.h"


@implementation Watcher


- (id)initWithURL:(NSURL *)url {
    if ((self = [super init])) {
        url_ = [url copy];
    }
    return self;
}


- (id)initWithCoder:(NSCoder*)coder {
    return [self initWithURL:[coder decodeObjectForKey:@"url"]];
}


- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:url_ forKey:@"url"];
}


- (void)dealloc {
    if (task_) [self unwatch];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [url_ release];
    [super dealloc];
}


- (void)watch {
    NSString *path = [url_ path];

    task_ = [[NSTask alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(terminated:)
                                                 name:NSTaskDidTerminateNotification
                                               object:task_];
    NSPipe *pipe = [NSPipe pipe];
    fileHandle_ = [pipe fileHandleForReading];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readPipe:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:fileHandle_];
    [fileHandle_ readInBackgroundAndNotify];
    
    NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
    NSString *node = [defaults objectForKey:@"node"];
    NSString *coffee = [defaults objectForKey:@"coffee"];
    NSArray *args = [NSArray arrayWithObjects:coffee, @"-w",  @"-b",  @"-o", path, path, nil];
    
    NSLog(@"watch: %@, %@", node, args);
    
    [task_ setLaunchPath:node];
    [task_ setArguments:args];
    [task_ setStandardOutput:pipe];
    [task_ setStandardError:pipe];
    [task_ launch];
}


- (void)terminated:(NSNotification *)notification {
    NSLog(@"terminated:%@", notification);
}


- (void)readPipe:(NSNotification *)notification {
    if ([notification object] != fileHandle_) return;
    
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([text length] > 0) {
        NSLog(@"%@", text);
        [LogWindow appendLog:text];
        BOOL failed;
        NSString *title;
        NSString *icon;
        if ((failed = [text hasPrefix:@"In "])) {
            title = @"Compile Failed";
            icon = @"cancel_48.png";
        } else {
            title = @"Compile Succeeded";
            icon = @"accepted_48.png";
        }
        [GrowlApplicationBridge notifyWithTitle:title
                                    description:text
                               notificationName:title
                                       iconData:[[NSImage imageNamed:icon] TIFFRepresentation]
                                       priority:0
                                       isSticky:failed
                                   clickContext:nil];
    }
    [text release];

    NSLog(@"readPipe:%d", [task_ isRunning]);
    if (task_ && [task_ isRunning]) {
        [fileHandle_ readInBackgroundAndNotify];
    } else {
        NSLog(@"%d", [task_ terminationStatus]);
        [self unwatch];
    }
}


- (void)unwatch {
    if (!task_) return;
    [task_ terminate];
    task_ = nil;

    NSData *data = [fileHandle_ readDataToEndOfFile];
    NSString *text = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"unwatch: %@", text);
    [LogWindow appendLog:text];
    [fileHandle_ closeFile];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSFileHandleReadCompletionNotification
                                                  object:fileHandle_];
    fileHandle_ = nil;
}


- (NSString *)path {
    return [url_ path];
}


@end
