//
//  TTOrderBookWindow.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/24/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTOrderBook.h"
#import "TTCurrency.h"

@interface TTOrderBookWindow : NSWindow <TTOrderBookDelegate>

@property(nonatomic, retain)TTOrderBook*orderBook;
@property(nonatomic, readonly)TTCurrency currency;

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag currency:(TTCurrency)currency;

@end
