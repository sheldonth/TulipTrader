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

typedef enum{
    TTDepthOrderUpdateTypeNone = 0,
    TTDepthOrderUpdateTypeInsert,
    TTDepthOrderUpdateTypeRemove,
    TTDepthOrderUpdateTypeUpdate
}TTDepthOrderUpdateType;

typedef enum{
    TTOrderBookSideNone = 0,
    TTOrderBookSideBid,
    TTOrderBookSideAsk
}TTOrderBookSide;

typedef enum{
    TTOrderBookConnectionStateNone = 0,
    TTOrderBookConnectionStateSocketUnavailable,
    TTOrderBookConnectionStateSocketDisconnected,
    TTOrderBookConnectionStateSocketConnected,
    TTOrderBookConnectionStateSocketConnecting
}TTOrderBookConnectionState;

@class TTOrderBook;

@interface TTDepthUpdate : NSObject

@property(nonatomic)NSInteger affectedIndex;
@property(nonatomic)TTDepthOrderUpdateType updateType;
@property(nonatomic)NSArray* updateArrayPointer;

@end

@protocol TTOrderBookDelegate <NSObject>

-(void)orderBook:(TTOrderBook*)orderBook hasNewDepthUpdate:(TTDepthUpdate*)update orderBookSide:(TTOrderBookSide)side;
-(void)orderBookHasNewTicker:(TTOrderBook*)orderBook;
-(void)orderBookHasNewLag:(TTOrderBook*)orderBook;
-(void)orderBookHasNewTrade:(TTOrderBook*)orderBook;

@end

@protocol TTOrderBookEventDelegate <NSObject>

-(void)orderBook:(TTOrderBook*)orderBook hasNewConnectionState:(TTOrderBookConnectionState)connectionState;
-(void)orderBook:(TTOrderBook*)orderBook hasNewEvent:(id)event;

@end

@protocol TTOrderBookAccountEventDelegate <NSObject>

-(void)settlementEventObserved:(NSDictionary *)eventData;
-(void)walletStateObserved:(NSDictionary *)walletDataDictionary;

@end



@interface TTOrderBook : NSObject <TTSocketControllerDelegate>

@property(nonatomic, retain)NSArray* bids;
@property(nonatomic, retain)NSArray* asks;
@property(nonatomic, retain)NSDictionary* maxMinTicks;
@property(nonatomic) TTCurrency currency;
@property(nonatomic, retain)TTTicker* lastTicker;
@property(nonatomic, retain)NSString* title;

@property(nonatomic)id<TTOrderBookDelegate>delegate;
@property(nonatomic)id<TTOrderBookEventDelegate>eventDelegate;
@property(nonatomic)id<TTOrderBookAccountEventDelegate>accountEventDelegate;

-(TTDepthOrder*)insideBuy;
-(TTDepthOrder*)insideSell;

-(NSNumber*)localQuoteFromOrderBookSide:(TTOrderBookSide)side forQuantity:(NSNumber*)qty;

+(TTOrderBook*)newOrderBookForMTGOXwithCurrency:(TTCurrency)currency;

//-(id)objectAtInvertedBidsIndex:(NSInteger)index;
-(id)initWithCurrency:(TTCurrency)currency;
-(void)start;

@end
