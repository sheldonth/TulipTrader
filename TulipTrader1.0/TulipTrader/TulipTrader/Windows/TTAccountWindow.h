//
//  TTAccountWindow.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/15/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTOrderBook.h"

typedef enum{
    TTAccountWindowExecutionStateNone = 0,
    TTAccountWindowExecutionStateBuying = 1,
    TTAccountWindowExecutionStateSelling
}TTAccountWindowExecutionState;

@interface TTAccountWindow : NSWindow <NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate>

@property(nonatomic, retain)TTOrderBook* orderbook;
@property(nonatomic)TTAccountWindowExecutionState executionState;

@end
