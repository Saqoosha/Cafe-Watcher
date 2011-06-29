//
//  PathListTable.m
//  CafeWatcher
//
//  Created by Tomohiko Koyama on 11/06/29.
//  Copyright 2011 Katamari Inc. All rights reserved.
//

#import "PathListTable.h"
#import "Watcher.h"


@implementation PathListTable


@synthesize paths = paths_;


- (void)awakeFromNib {
    [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    [self setDataSource:self];
}


- (void)dealloc {
    [super dealloc];
}


- (NSDragOperation)tableView:(NSTableView *)aTableView
                validateDrop:(id < NSDraggingInfo >)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)operation {

    if (operation == NSTableViewDropOn) {
        return NSDragOperationNone;
    }

    NSPasteboard *pasteBoard = [info draggingPasteboard];
    NSArray *files = [pasteBoard propertyListForType:NSFilenamesPboardType];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    int dirs = 0;
    BOOL isDir;
    for (NSString *file in files) {
        if ([fileManager fileExistsAtPath:file isDirectory:&isDir]) {
            if (isDir) dirs++;
        }
    }

    if (dirs > 0) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}


- (BOOL)tableView:(NSTableView *)aTableView
       acceptDrop:(id < NSDraggingInfo >)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)operation {

    NSPasteboard *pasteBoard = [info draggingPasteboard];
    NSArray *files = [pasteBoard propertyListForType:NSFilenamesPboardType];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    int dirs = 0;
    BOOL isDir;
    for (NSString *file in files) {
        if ([fileManager fileExistsAtPath:file isDirectory:&isDir]) {
            if (isDir) {
                NSURL *url = [NSURL fileURLWithPath:file];
                Watcher *watcher = [[[Watcher alloc] initWithURL:url] autorelease];
                [paths_ insertObject:watcher atArrangedObjectIndex:row];
                row++;
                dirs++;
            }
        }
    }
    if (dirs > 0) {
        return YES;
    }
    return NO;
}


@end
