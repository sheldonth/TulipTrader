
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
#import "TTGoxHTTPController.h"
#import "TTDepthOrder.h"

@interface TTOrderBook()

@property(nonatomic, retain)TTSocketController* websocket;
@property(nonatomic, retain)TTGoxHTTPController* httpController;
@property(nonatomic)BOOL firstLoad;

@end

@implementation TTOrderBook

NSUInteger indexSetOfObjectWithPrice(NSArray* array, TTDepthOrder* depthOrder)
{
    NSIndexSet* indexSet = [array indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj price]isEqualToNumber:depthOrder.price])
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (indexSet.count != 1)
    {
        return NSNotFound;
    }
    else
        return [indexSet firstIndex];
}

NSArray* arrayAfterAddingDepthOrder(NSArray* array, TTDepthOrder* depthOrder)
{
    NSUInteger index = indexSetOfObjectWithPrice(array, depthOrder);
    
    if (index == NSNotFound)
    {
        NSMutableArray* mutableCpy = [array mutableCopy];
        [mutableCpy addObject:depthOrder];
        [mutableCpy sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES]]];
        return mutableCpy;
    }
    else
    {
        TTDepthOrder* depthOrderBeingModified = [array objectAtIndex:index];
        [depthOrderBeingModified setAmount:@(depthOrderBeingModified.amount.floatValue + depthOrder.amount.floatValue)];
        NSMutableArray* mutablePtr = [array mutableCopy];
        [mutablePtr replaceObjectAtIndex:index withObject:depthOrderBeingModified];
        return mutablePtr;
    }
}

NSArray* arrayAfterRemovingDepthOrder(NSArray* array, TTDepthOrder* depthOrder)
{
    NSUInteger index = indexSetOfObjectWithPrice(array, depthOrder);
    
    if (index == NSNotFound)
        RUDLog(@"Didn't find price to remove amount from");
    
    TTDepthOrder* depthOrderBeingModified = [array objectAtIndex:index];
    if ([depthOrderBeingModified.amount isEqualToNumber:depthOrder.amount])
    {
        NSMutableArray* mutablePtr = [array mutableCopy];
        [mutablePtr removeObjectAtIndex:index];
        return mutablePtr;
    }
    else
    {
        [depthOrderBeingModified setAmount:@(depthOrderBeingModified.amount.floatValue - depthOrder.amount.floatValue)];
        NSMutableArray* mutableArray = [array mutableCopy];
        [mutableArray replaceObjectAtIndex:index withObject:depthOrderBeingModified];
        return mutableArray;
    }
}

-(void)removeAskOrder:(TTDepthOrder*)ord
{
    [self setAsks:arrayAfterRemovingDepthOrder(self.asks, ord)];
}

-(void)removeBidOrder:(TTDepthOrder*)ord
{
    [self setBids:arrayAfterRemovingDepthOrder(self.bids, ord)];
}

-(void)addAskOrder:(TTDepthOrder*)ord
{
    [self setAsks:arrayAfterAddingDepthOrder(self.asks, ord)];
}

-(void)addBidOrder:(TTDepthOrder*)ord
{
    [self setBids:arrayAfterAddingDepthOrder(self.bids, ord)];
}

-(void)socketController:(TTSocketController*)socketController orderBookDeltaObserved:(TTDepthOrder*)orderBookDelta;
{
    switch (orderBookDelta.depthDeltaAction) {
        case TTDepthOrderActionAdd:
        {
            if (orderBookDelta.depthDeltaType == TTDepthOrderTypeBid)
                [self addBidOrder:orderBookDelta];
            else if (orderBookDelta.depthDeltaType == TTDepthOrderTypeAsk)
                [self addAskOrder:orderBookDelta];
            else
                {NSException* e = [NSException exceptionWithName:NSInternalInconsistencyException reason:@"No type on socket depth" userInfo:nil];@throw e;}
            break;
        }
        case TTDepthOrderActionRemove:
        {
            if (orderBookDelta.depthDeltaType == TTDepthOrderTypeBid)
                [self removeBidOrder:orderBookDelta];
            else if (orderBookDelta.depthDeltaType == TTDepthOrderTypeAsk)
                [self removeAskOrder:orderBookDelta];
            else
                {NSException* e = [NSException exceptionWithName:NSInternalInconsistencyException reason:@"No type on socket depth" userInfo:nil];@throw e;}
            break;
        }
        case TTDepthOrderActionNone:
        {
            NSException* e = [NSException exceptionWithName:NSInternalInconsistencyException reason:@"No action on socket depth" userInfo:nil];
            @throw e;
            break;
        }
        default:
            break;
    }
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
     
    [self.httpController getFullDepthForCurrency:self.currency withCompletion:^(NSArray *bids, NSArray *asks, NSDictionary *maxMinTicks) {
        // Using iVars so as not to set of observers until the bids or asks are updated by the websocket.
        _bids = bids;
        _asks = asks;
        [self setFirstLoad:YES];
        [self.websocket open];
    } withFailBlock:^(NSError *e) {
        
    }];
}



@end
