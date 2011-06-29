//
//  PathListTable.h
//  CafeWatcher
//
//  Created by Tomohiko Koyama on 11/06/29.
//  Copyright 2011 Katamari Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PathListTable : NSTableView {
@private
    NSArrayController *paths_;
}

@property (assign) IBOutlet NSArrayController *paths;


@end
