//
//  LogWindow.h
//  CafeWatcher
//
//  Created by hiko on 11/06/26.
//  Copyright 2011 Katamari Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LogWindow : NSWindow {
    
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSTextView *textView;
}

+ (void)appendLog:(NSString *)log;
- (void)writeText:(NSString *)text;

@end
