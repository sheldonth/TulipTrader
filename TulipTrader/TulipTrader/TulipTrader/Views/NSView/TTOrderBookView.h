//
//  TTOrderBookView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/24/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTOrderBook.h"
#import "TTCurrency.h"

@interface TTOrderBookView : NSView <TTOrderBookDelegate>

@property(nonatomic, retain)TTOrderBook*orderBook;
@property(nonatomic, readonly)TTCurrency currency;

-(id)initWithFrame:(NSRect)frameRect currency:(TTCurrency)currency;

@end
