
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

#define NOISYORDERBOOK 1

#pragma mark - Static per-market constructors

+(TTOrderBook*)newOrderBookForMTGOXwithCurrency:(TTCurrency)currency
{
    TTOrderBook* orderBook = [[TTOrderBook alloc]initWithCurrency:currency];
    [orderBook setWebsocket:[TTGoxSocketController new]];
    [orderBook setHttpController:[TTGoxHTTPController new]];
    [orderBook setTitle:RUStringWithFormat(@"MtGox%@", stringFromCurrency(currency))];
    return orderBook;
}

#pragma mark - C style sorting methods

NSUInteger indexSetOfObjectWithPrice(NSArray* array, TTDepthOrder* depthOrder)
{
    NSIndexSet* indexSet = [array indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj priceInt] == depthOrder.priceInt)
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
        if (NOISYORDERBOOK) RUDLog(@"+ %@ at %@",depthOrder.amount, depthOrder.price);
        NSMutableArray* mutableCpy = [array mutableCopy];
        [mutableCpy addObject:depthOrder];
        [mutableCpy sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES]]];
        return mutableCpy;
    }
    else
    {
        if (NOISYORDERBOOK) RUDLog(@"+ %@ p at %@",depthOrder.amount, depthOrder.price);
        TTDepthOrder* depthOrderBeingModified = [array objectAtIndex:index];
        [depthOrderBeingModified setAmount:@(depthOrderBeingModified.amount.floatValue + depthOrder.amount.floatValue)];
        [depthOrderBeingModified setAmountInt:depthOrderBeingModified.amountInt + depthOrder.amountInt];
        NSMutableArray* mutablePtr = [array mutableCopy];
        [mutablePtr replaceObjectAtIndex:index withObject:depthOrderBeingModified];
        return mutablePtr;
    }
}

NSArray* arrayAfterRemovingDepthOrder(NSArray* array, TTDepthOrder* depthOrder)
{
    NSUInteger index = indexSetOfObjectWithPrice(array, depthOrder);
    
    if (index == NSNotFound)
    {
        if (NOISYORDERBOOK) RUDLog(@"Inconsistent depth change message: %@", depthOrder);
        return array;
    }
    TTDepthOrder* depthOrderBeingModified = [array objectAtIndex:index];
    if (depthOrderBeingModified.amountInt == depthOrder.amountInt)
    {
        if (NOISYORDERBOOK) RUDLog(@"- %@ at %@",depthOrder.amount, depthOrder.price);
        NSMutableArray* mutablePtr = [array mutableCopy];
        [mutablePtr removeObjectAtIndex:index];
        return mutablePtr;
    }
    else
    {
        if (NOISYORDERBOOK) RUDLog(@"- %@ p at %@",depthOrder.amount, depthOrder.price);
        if (depthOrderBeingModified.amountInt < depthOrder.amountInt)
            RUDLog(@"NEGATIVE BALANCE");
        [depthOrderBeingModified setAmount:@(depthOrderBeingModified.amount.floatValue - depthOrder.amount.floatValue)];
        [depthOrderBeingModified setAmountInt:depthOrderBeingModified.amountInt - depthOrder.amountInt];
        NSMutableArray* mutableArray = [array mutableCopy];
        [mutableArray replaceObjectAtIndex:index withObject:depthOrderBeingModified];
        return mutableArray;
    }
}

#pragma mark - logical order book

-(void)removeAskOrder:(TTDepthOrder*)ord
{
    [self setAsks:arrayAfterRemovingDepthOrder(self.asks, ord)];
    [self.delegate orderBookHasNewDepth:self];
}

-(void)removeBidOrder:(TTDepthOrder*)ord
{
    [self setBids:arrayAfterRemovingDepthOrder(self.bids, ord)];
    [self.delegate orderBookHasNewDepth:self];
}

-(void)addAskOrder:(TTDepthOrder*)ord
{
    [self setAsks:arrayAfterAddingDepthOrder(self.asks, ord)];
    [self.delegate orderBookHasNewDepth:self];
}

-(void)addBidOrder:(TTDepthOrder*)ord
{
    [self setBids:arrayAfterAddingDepthOrder(self.bids, ord)];
    [self.delegate orderBookHasNewDepth:self];
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
    [self setLastTicker:theTicker];
    [self.delegate orderBookHasNewTicker:self];
}

-(void)socketController:(TTSocketController *)socketController tradeObserved:(TTTrade *)theTrade
{
    RUDLog(@"tradeObserved");
    [self.delegate orderBookHasNewTrade:self];
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
        // Using iVars so as not to set of observers until the bids or asks are updated by the websocket.
        _bids = bids;
        _asks = asks;
        [self setFirstLoad:YES];
        [self.websocket openWithCurrency:self.currency];
    } withFailBlock:^(NSError *e) {
        RUDLog(@"FAIL");
    }];
}



@end
