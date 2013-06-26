//
//  TTOrderBook.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/21/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTSocketController.h"
#import "TTCurrency.h"
#import "TTTicker.h"

@class TTOrderBook;

@protocol TTOrderBookDelegate <NSObject>

-(void)orderBookHasNewDepth:(TTOrderBook*)orderBook;
-(void)orderBookHasNewTicker:(TTOrderBook*)orderBook;
-(void)orderBookHasNewLag:(TTOrderBook*)orderBook;
-(void)orderBookHasNewTrade:(TTOrderBook*)orderBook;

@end

@interface TTOrderBook : NSObject <TTSocketControllerDelegate>

@property(nonatomic, retain)NSArray* bids;
@property(nonatomic, retain)NSArray* asks;
@property(nonatomic, retain)NSDictionary* maxMinTicks;
@property(nonatomic) TTCurrency currency;
@property(nonatomic, retain)TTTicker* lastTicker;
@property(nonatomic, retain)NSString* title;

@property(nonatomic, retain)id<TTOrderBookDelegate>delegate;

+(TTOrderBook*)newOrderBookForMTGOXwithCurrency:(TTCurrency)currency;

-(id)initWithCurrency:(TTCurrency)currency;
-(void)start;

@end
