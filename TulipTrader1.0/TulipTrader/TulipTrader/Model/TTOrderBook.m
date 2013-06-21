//
//  TTOrderBook.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/21/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTOrderBook.h"
#import "TTGoxSocketController.h"
#import "TTGoxHTTPController.h"
#import "RUConstants.h"

@interface TTOrderBook()

@property(nonatomic, retain)TTSocketController* websocket;
@property(nonatomic, retain)TTHTTPController* httpController;
@property(nonatomic)BOOL firstLoad;

@end

@implementation TTOrderBook

-(void)socketController:(TTSocketController*)socketController orderBookDeltaObserved:(TTDepthOrder*)orderBookDelta;
{
    RUDLog(@"!");
}

-(void)socketController:(TTSocketController *)socketController tickerObserved:(TTTicker *)theTicker
{
    RUDLog(@"!");
}

-(void)socketController:(TTSocketController *)socketController tradeObserved:(TTTrade *)theTrade
{
    RUDLog(@"!");
}

+(TTOrderBook*)newOrderBookForMTGOXwithCurrency:(TTCurrency)currency
{
    TTOrderBook* orderBook = [[TTOrderBook alloc]initWithCurrency:currency];
    [orderBook setWebsocket:[TTGoxSocketController new]];
    [orderBook setHttpController:[TTGoxHTTPController new]];
    return orderBook;
}

-(id)initWithCurrency:(TTCurrency)currency
{
    self = [super init];
    if (self)
    {
        [self setCurrency:currency];
        [self setFirstLoad:NO];
    }
    return self;
}

-(void)start
{
    [self.websocket setDelegate:self];
    [self.httpController getDepthForCurrency:self.currency withCompletion:^(NSArray *bids, NSArray *asks, NSDictionary *maxMinTicks) {
        _bids = bids;
        _asks = asks;
        _maxMinTicks = maxMinTicks;
        [self setFirstLoad:YES];
        [self.websocket open];
    } withFailBlock:^(NSError *e) {
        RUDLog(@"!");
    }];
}



@end
