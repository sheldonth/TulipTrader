//
//  TTCurrencyBox.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/25/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTCurrency.h"
#import "TTOrderBook.h"
#import "TTTicker.h"

@interface TTCurrencyBox : NSBox

@property(nonatomic, weak)TTOrderBook* orderBookPtr;
@property(nonatomic, retain)TTTicker* lastTicker;

@end
