//
//  TTOrderBookListView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/26/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TTOrderBookListView : NSView <NSTableViewDataSource, NSTableViewDelegate>

@property(nonatomic, retain)NSArray* orders;
@property(nonatomic, retain)NSTableColumn* positionColumn;
@property(nonatomic, retain)NSTableColumn* priceColumn;
@property(nonatomic, retain)NSTableColumn* amountColumn;
@property(nonatomic, retain)NSTableColumn* sumColumn;
@property(nonatomic, retain)NSTableColumn* ageColumn;

-(void)setTitle:(NSString*)titleString;

@end
