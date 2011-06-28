//
//  LogWindow.m
//  CafeWatcher
//
//  Created by hiko on 11/06/26.
//  Copyright 2011 Katamari Inc. All rights reserved.
//

#import "LogWindow.h"


static LogWindow *instance_;


@implementation LogWindow


+ (void)appendLog:(NSString *)log {
    [instance_ writeText:log];
}


- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    if ((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag])) {
        instance_ = self;
        dateFormatter_ = [[NSDateFormatter alloc] init];
        [dateFormatter_ setDateFormat:@"HH:mm:ss.SSS"];
    }
    return self;
}


- (void)writeText:(NSString *)text {
    // determine if we should scroll to the end
    bool scrollToEnd = YES;
    
    if ([scrollView hasVerticalScroller]) {
        if (textView.frame.size.height > [scrollView frame].size.height) {
            if (1.0f != [scrollView verticalScroller].floatValue)
                scrollToEnd = NO;
        }
    }
    
    NSFont *font = [NSFont fontWithName:@"Menlo" size:12.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    NSString *str = [NSString stringWithFormat:@"%@: %@", [dateFormatter_ stringFromDate:[NSDate date]], text];
    NSAttributedString *stringToAppend = [[[NSAttributedString alloc] initWithString:str attributes:attributes] autorelease];
    [[textView textStorage] appendAttributedString:stringToAppend];
    
    if (scrollToEnd) {
        // scroll to the end
        NSRange range = NSMakeRange([[textView string] length], 0);
        [textView scrollRangeToVisible: range];
    }
}


- (IBAction)clear:(id)sender {
    NSRange range = NSMakeRange(0, [[textView string] length]);
    [[textView textStorage] deleteCharactersInRange:range];
}


@end
