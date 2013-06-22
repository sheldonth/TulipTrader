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

@interface TTOrderBook : NSObject <TTSocketControllerDelegate>

@property(nonatomic, retain)NSArray* bids;
@property(nonatomic, retain)NSArray* asks;
@property(nonatomic, retain)NSDictionary* maxMinTicks;
@property(nonatomic) TTCurrency currency;

+(TTOrderBook*)newOrderBookForMTGOXwithCurrency:(TTCurrency)currency;

-(id)initWithCurrency:(TTCurrency)currency;

-(void)start;

@end
