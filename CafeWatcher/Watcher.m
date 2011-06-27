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
        state_ = 0;
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
    [url_ release];
    [super dealloc];
}


- (void)watch {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readPipe:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:nil];

    NSString *path = [url_ path];
    NSLog(@"Watch start: %@", path);

    task_ = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];
    fileHandle_ = [pipe fileHandleForReading];
    [fileHandle_ readInBackgroundAndNotify];

    [task_ setLaunchPath:@"/Users/hiko/.nvm/v0.4.7/bin/node"];
    [task_ setArguments:[NSArray arrayWithObjects:@"/Users/hiko/.nvm/v0.4.7/bin/coffee", @"-w",  @"-b",  @"-o", path, path, nil]];
    [task_ setStandardOutput:pipe];
    [task_ setStandardError:pipe];
    [task_ launch];
}


- (void)readPipe:(NSNotification *)notification {
    if ([notification object] != fileHandle_) return;
    
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSLog(@"%@", text);
    [LogWindow appendLog:text];
    NSString *title;
    if ([text hasPrefix:@"In "]) {
        title = @"Compile Failed";
    } else {
        title = @"Compile Succeeded";
    }
    [GrowlApplicationBridge notifyWithTitle:title
                                description:text
                           notificationName:title
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:nil];
    
    [text release];
    if (task_) [fileHandle_ readInBackgroundAndNotify];
}


- (void)unwatch {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (!task_) return;
    [task_ terminate];
    task_ = nil;
    [fileHandle_ closeFile];
    fileHandle_ = nil;
}


- (NSString *)path {
    return [url_ path];
}


- (int)state {
    return state_;
}

- (void)setState:(int)state {
    state_ = state;
}


@end
