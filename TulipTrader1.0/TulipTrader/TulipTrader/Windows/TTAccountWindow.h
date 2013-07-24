//
//  TTAccountWindow.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/15/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTOrderBook.h"

@interface TTAccountWindow : NSWindow <NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, TTOrderBookAccountEventDelegate>

@property(nonatomic, retain)TTOrderBook* orderbook;

-(void)reloadAccountData;

@end
