//
//  Watcher.h
//  CafeWatcher
//
//  Created by hiko on 11/06/24.
//  Copyright 2011 Katamari Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Watcher : NSObject <NSCoding> {
    
@private
    NSURL *url_;
    NSMutableDictionary *fileStats_;
}

- (id)initWithURL:(NSURL *)url;
- (void)compileModifiedFiles;
- (NSString *)path;

@end
