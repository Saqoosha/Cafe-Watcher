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


#define kSuccessIcon    @"accepted_48.png"
#define kErrorIcon      @"cancel_48.png"


@interface Watcher(Private)
- (void)compileAll;
- (void)compileCoffee:(NSURL *)file;
- (void)notifyResult:(NSString *)title icon:(NSString *)icon text:(NSString *)text isSticky:(BOOL)isSticky;
@end


@implementation Watcher


- (id)initWithURL:(NSURL *)url {
    if ((self = [super init])) {
        url_ = [url copy];
        fileStats_ = [[NSMutableDictionary alloc] init];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        NSDirectoryEnumerator *dir = [manager enumeratorAtPath:[url_ path]];
        NSString *file;
        while ((file = [dir nextObject])) {
            [fileStats_ setObject:[[dir fileAttributes] fileModificationDate] forKey:file];
        }
        [self compileAll];
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
    [url_ release];
    [fileStats_ release];
    [super dealloc];
}


- (void)compileAll {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dir = [manager enumeratorAtPath:[url_ path]];
    NSString *file;
    while ((file = [dir nextObject])) {
        NSDate *modified = [[dir fileAttributes] fileModificationDate];
        if ([file hasSuffix:@".coffee"]) {
            [self compileCoffee:[url_ URLByAppendingPathComponent:file]];
        }
        [fileStats_ setObject:modified forKey:file];
    }
}


- (void)compileModifiedFiles {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dir = [manager enumeratorAtPath:[url_ path]];
    NSString *file;
    while ((file = [dir nextObject])) {
        NSDate *prev = [fileStats_ objectForKey:file];
        NSDate *modified = [[dir fileAttributes] fileModificationDate];
        if (prev == nil || [prev compare:modified] == NSOrderedAscending) {
            if ([file hasSuffix:@".coffee"]) {
                [self compileCoffee:[url_ URLByAppendingPathComponent:file]];
            }
        }
        [fileStats_ setObject:modified forKey:file];
    }
}


- (void)compileCoffee:(NSURL *)fileURL {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
    NSString *node = [defaults objectForKey:@"node"];
    if (![manager fileExistsAtPath:node]) {
        [self notifyResult:@"Node executable not found"
                      icon:kErrorIcon
                      text:@"Please install Node and set correct path at Preferences."
                  isSticky:NO];
        NSBeep();
        return;
    }
    NSString *coffee = [defaults objectForKey:@"coffee"];
    if (![manager fileExistsAtPath:coffee]) {
        [self notifyResult:@"CoffeeScript compiler not found"
                      icon:kErrorIcon
                      text:@"Please install CoffeeScript and set correct path at Preferences."
                  isSticky:NO];
        NSBeep();
        return;
    }
    NSMutableArray *args = [NSMutableArray arrayWithObject:coffee];
    if ([defaults boolForKey:@"bare"]) {
        [args addObject:@"-b"];
    }
    [args addObject:@"-c"];
    [args addObject:[fileURL path]];
//    NSLog(@"compileCoffee: %@, %@", node, args);
    
    NSTask *task = [[[NSTask alloc] init] autorelease];
    NSPipe *pipe = [NSPipe pipe];
    [task setLaunchPath:node];
    [task setArguments:args];
    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    [task launch];
    [task waitUntilExit];
    
    if ([task terminationStatus] == 0) {
        [self notifyResult:@"Compile Succeeded" icon:kSuccessIcon text:[fileURL path] isSticky:NO];
    } else {
        NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
        NSString *text = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        NSLog(@"%@", text);
        NSArray *lines = [text componentsSeparatedByString:@"\n"];
        [self notifyResult:@"Compile Failed" icon:kErrorIcon text:[lines objectAtIndex:0] isSticky:YES];
        NSBeep();
    }
}


- (void)notifyResult:(NSString *)title icon:(NSString *)icon text:(NSString *)text isSticky:(BOOL)isSticky {
    [LogWindow appendLog:[NSString stringWithFormat:@"%@: %@\n", title, text]];
    [GrowlApplicationBridge notifyWithTitle:title
                                description:text
                           notificationName:title
                                   iconData:[[NSImage imageNamed:icon] TIFFRepresentation]
                                   priority:0
                                   isSticky:isSticky
                               clickContext:nil];
}


- (NSString *)path {
    return [url_ path];
}


@end
