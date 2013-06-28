
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

@implementation TTDepthUpdate

@end

@implementation TTOrderBook

#define NOISYORDERBOOK 0
#define NOISYMISTAKES 1

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

TTDepthUpdate* updateObjectAfterAddingDepthOrder(NSArray* array, TTDepthOrder* depthOrder)
{
    TTDepthUpdate* updateObj = [TTDepthUpdate new];
    
    NSUInteger index = indexSetOfObjectWithPrice(array, depthOrder);
    
    if (index == NSNotFound)
    {
        if (NOISYORDERBOOK) RUDLog(@"+ %@ at %@",depthOrder.amount, depthOrder.price);
        [updateObj setUpdateType:TTDepthOrderUpdateTypeInsert];
        NSMutableArray* mutableCpy = [array mutableCopy];
        [mutableCpy addObject:depthOrder];
        [mutableCpy sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES]]];
        NSUInteger i = [mutableCpy indexOfObject:depthOrder];
        [updateObj setAffectedIndex:i];
        if (NOISYMISTAKES)
        {
            if (depthOrder.totalVolumeInt != depthOrder.amountInt)
                RUDLog(@"Created order for %li at %li, server said final volume should've been %li", depthOrder.amountInt, depthOrder.priceInt, depthOrder.totalVolumeInt);
        }
        [updateObj setUpdateArrayPointer:mutableCpy];
    }
    else
    {
        if (NOISYORDERBOOK) RUDLog(@"+ %@ p at %@",depthOrder.amount, depthOrder.price);
        [updateObj setAffectedIndex:index];
        [updateObj setUpdateType:TTDepthOrderUpdateTypeUpdate];
        TTDepthOrder* depthOrderBeingModified = [array objectAtIndex:index];
        [depthOrderBeingModified setAmount:@(depthOrderBeingModified.amount.floatValue + depthOrder.amount.floatValue)];
        [depthOrderBeingModified setAmountInt:depthOrderBeingModified.amountInt + depthOrder.amountInt];
        NSMutableArray* mutablePtr = [array mutableCopy];
        [mutablePtr replaceObjectAtIndex:index withObject:depthOrderBeingModified];
        if (NOISYMISTAKES)
        {
            if (depthOrder.totalVolumeInt != depthOrderBeingModified.amountInt)
                RUDLog(@"Added to depth order and got %li server expected %li", depthOrderBeingModified.amountInt, depthOrder.totalVolumeInt);
        }
        [updateObj setUpdateArrayPointer:mutablePtr];
    }
    return updateObj;
}

TTDepthUpdate* updateObjectAfterRemovingDepthOrder(NSArray* array, TTDepthOrder* depthOrder)
{
    TTDepthUpdate* updateObj = [TTDepthUpdate new];
    NSUInteger index = indexSetOfObjectWithPrice(array, depthOrder);
    
    if (index == NSNotFound)
    {
        if (NOISYMISTAKES) RUDLog(@"Order not present at %li", depthOrder.priceInt);//if (NOISYORDERBOOK)
        [updateObj setUpdateType:TTDepthOrderUpdateTypeNone];
        [updateObj setUpdateArrayPointer:array];
        return updateObj;
    }
    
    [updateObj setAffectedIndex:index];
    
    TTDepthOrder* depthOrderBeingModified = [array objectAtIndex:index];
    
    if (depthOrderBeingModified.amountInt == depthOrder.amountInt)
    {
        if (NOISYORDERBOOK) RUDLog(@"- %@ at %@",depthOrder.amount, depthOrder.price);
        [updateObj setUpdateType:TTDepthOrderUpdateTypeRemove];
        NSMutableArray* mutablePtr = [array mutableCopy];
        [mutablePtr removeObjectAtIndex:index];
        if (NOISYMISTAKES)
        {
            if (depthOrder.totalVolumeInt != 0)
                RUDLog(@"Order being removed when server indicated remaining value");
        }
        [updateObj setUpdateArrayPointer:mutablePtr];
    }
    else
    {
        if (NOISYORDERBOOK) RUDLog(@"- %@ p at %@",depthOrder.amount, depthOrder.price);
        if (NOISYMISTAKES)
        {
            if (depthOrderBeingModified.amountInt < depthOrder.amountInt)
                RUDLog(@"NEGATIVE BALANCE");
        }
        [updateObj setUpdateType:TTDepthOrderUpdateTypeUpdate];
        [depthOrderBeingModified setAmount:@(depthOrderBeingModified.amount.floatValue - depthOrder.amount.floatValue)];
        [depthOrderBeingModified setAmountInt:(depthOrderBeingModified.amountInt - depthOrder.amountInt)];
        NSMutableArray* mutableArray = [array mutableCopy];
        if (NOISYMISTAKES)
        {
            if (depthOrderBeingModified.amountInt != depthOrder.totalVolumeInt)
                RUDLog(@"Server Expected: %li We Got: %li", depthOrder.totalVolumeInt, depthOrderBeingModified.amountInt);
        }
        [mutableArray replaceObjectAtIndex:index withObject:depthOrderBeingModified];
        [updateObj setUpdateArrayPointer:mutableArray];
    }
    return updateObj;
}

#pragma mark - logical order book

-(void)addAskOrder:(TTDepthOrder*)ord
{
    TTDepthUpdate* update = updateObjectAfterAddingDepthOrder(self.asks, ord);
    [self setAsks:update.updateArrayPointer];
    [self.delegate orderBook:self hasNewDepthUpdate:update orderBookSide:TTOrderBookSideAsk];
}

-(void)removeAskOrder:(TTDepthOrder*)ord
{
    TTDepthUpdate* update = updateObjectAfterRemovingDepthOrder(self.asks, ord);
    [self setAsks:update.updateArrayPointer];
    [self.delegate orderBook:self hasNewDepthUpdate:update orderBookSide:TTOrderBookSideAsk];
}

-(void)addBidOrder:(TTDepthOrder*)ord
{
    TTDepthUpdate* update = updateObjectAfterAddingDepthOrder(self.bids, ord);
    [self setBids:update.updateArrayPointer];
    [self.delegate orderBook:self hasNewDepthUpdate:update orderBookSide:TTOrderBookSideBid];
}

-(void)removeBidOrder:(TTDepthOrder*)ord
{
    TTDepthUpdate* update = updateObjectAfterRemovingDepthOrder(self.bids, ord);
    [self setBids:update.updateArrayPointer];
    [self.delegate orderBook:self hasNewDepthUpdate:update orderBookSide:TTOrderBookSideBid];
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
        TTDepthUpdate* bidUpdate = [TTDepthUpdate new];
        [bidUpdate setUpdateType:(TTDepthOrderUpdateTypeNone)];
        [bidUpdate setUpdateArrayPointer:_bids];
        
        TTDepthUpdate* askUpdate = [TTDepthUpdate new];
        [askUpdate setUpdateType:(TTDepthOrderUpdateTypeNone)];
        [askUpdate setUpdateArrayPointer:_asks];
        
        
        [self.delegate orderBook:self hasNewDepthUpdate:bidUpdate orderBookSide:(TTOrderBookSideBid)];
        [self.delegate orderBook:self hasNewDepthUpdate:askUpdate orderBookSide:(TTOrderBookSideAsk)];
        [self setFirstLoad:YES];
        [self.websocket openWithCurrency:self.currency];
    } withFailBlock:^(NSError *e) {
        RUDLog(@"FAIL");
    }];
}



@end
