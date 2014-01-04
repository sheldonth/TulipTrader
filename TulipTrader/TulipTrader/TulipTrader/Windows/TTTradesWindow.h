//
//  TTTradesWindow.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/7/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TTTrade;

@interface TTTradesWindow : NSWindow <NSTableViewDataSource, NSTableViewDelegate>

@property(nonatomic, retain)NSArray* trades;
@property(nonatomic, readonly)NSScrollView* scrollView;
@property(nonatomic, readonly)NSTableView* tableView;

-(void)addTrade:(TTTrade*)trade;

@end
