
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
#import "RulesPreferencesViewController.h"

@interface TTOrderBook()

@property(nonatomic, retain)TTSocketController* websocket;
@property(nonatomic, retain)TTGoxHTTPController* httpController;
@property(nonatomic)BOOL firstLoad;

@end

@implementation TTDepthUpdate

@end

@implementation TTOrderBook

#define NOISYORDERBOOK 0
#define NOISYMISTAKES 0

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

        if (depthOrder.totalVolumeInt != depthOrder.amountInt)
        {
            if (NOISYMISTAKES) RUDLog(@"Created order for %li at %li, server said final volume should've been %li", depthOrder.amountInt, depthOrder.priceInt, depthOrder.totalVolumeInt);
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
        if (NOISYMISTAKES)
            RUDLog(@"Order not present at %li -- total_vol: %li adjusted to float: %f", depthOrder.priceInt, depthOrder.totalVolumeInt, (float)depthOrder.totalVolumeInt / 100000000.f);
        
        if ([depthOrder totalVolumeInt])
        {
            // Since we do not have a depth order to modify, however the totalVolumeInt indicates a remaining depth, set the amount of the depth order
            // to that totalVolumeInt adjusted for float and insert, sort and organize that.
            [updateObj setUpdateType:TTDepthOrderUpdateTypeInsert];
            [depthOrder setAmountInt:depthOrder.totalVolumeInt];
            [depthOrder setAmount:@((float)depthOrder.totalVolumeInt / 100000000.f)];
            NSMutableArray* mutableCpy = [array mutableCopy];
            [mutableCpy addObject:depthOrder];
            [mutableCpy sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES]]];
            NSUInteger i = [mutableCpy indexOfObject:depthOrder];
            [updateObj setAffectedIndex:i];
            [updateObj setUpdateArrayPointer:mutableCpy];
        }
        else
        {
            // The total volume is 0, since we didn't find a depth order we were aiming to remove anyways, set the update type to none and move along.
            [updateObj setUpdateType:TTDepthOrderUpdateTypeNone];
            [updateObj setUpdateArrayPointer:array];
        }
    }
    else
    {
        [updateObj setAffectedIndex:index];
        
        TTDepthOrder* depthOrderBeingModified = [array objectAtIndex:index];
        
        if (depthOrderBeingModified.amountInt == depthOrder.amountInt)
        {
            if (NOISYORDERBOOK) RUDLog(@"- %@ at %@",depthOrder.amount, depthOrder.price);
            [updateObj setUpdateType:TTDepthOrderUpdateTypeRemove];
            NSMutableArray* mutablePtr = [array mutableCopy];
            [mutablePtr removeObjectAtIndex:index];
            if (depthOrder.totalVolumeInt != 0)
            {
                if (NOISYMISTAKES)
                {
                    RUDLog(@"Removed Complete Order, Server indicated remaining value: %f", (float)depthOrder.totalVolumeInt / 100000000.f);
                }
            }
            [updateObj setUpdateArrayPointer:mutablePtr];
        }
        else
        {
            if (NOISYORDERBOOK) RUDLog(@"- %@ p at %@",depthOrder.amount, depthOrder.price);
            if (depthOrderBeingModified.amountInt < depthOrder.amountInt)
            {
                [updateObj setUpdateType:TTDepthOrderUpdateTypeRemove];
                NSMutableArray* mutableCpy = [array mutableCopy];
                [mutableCpy removeObjectAtIndex:index];
                [updateObj setUpdateArrayPointer:mutableCpy];
            }
            else
            {
                [updateObj setUpdateType:TTDepthOrderUpdateTypeUpdate];
                [depthOrderBeingModified setAmount:@(depthOrderBeingModified.amount.floatValue - depthOrder.amount.floatValue)];
                [depthOrderBeingModified setAmountInt:(depthOrderBeingModified.amountInt - depthOrder.amountInt)];
                [updateObj setUpdateArrayPointer:array];
            }
        }

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
    [self.eventDelegate orderBook:self hasNewEvent:orderBookDelta];
}

-(void)socketController:(TTSocketController *)socketController tickerObserved:(TTTicker *)theTicker
{
    [self setLastTicker:theTicker];
    [self.delegate orderBookHasNewTicker:self];
    NSArray* inconsistentInsideBids = [self.bids filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"priceInt > %@", theTicker.buy.value_int]];
    [inconsistentInsideBids enumerateObjectsUsingBlock:^(TTDepthOrder* obj, NSUInteger idx, BOOL *stop) {
        [self removeBidOrder:obj];
    }];
    NSArray* inconsistentInsideAsks = [self.asks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"priceInt < %@", theTicker.sell.value_int]];
    [inconsistentInsideAsks enumerateObjectsUsingBlock:^(TTDepthOrder* obj, NSUInteger idx, BOOL *stop) {
        [self removeAskOrder:obj];
    }];
    [self.eventDelegate orderBook:self hasNewEvent:theTicker];
}

-(void)socketController:(TTSocketController *)socketController tradeObserved:(TTTrade *)theTrade
{
    [self.delegate orderBookHasNewTrade:self];
    [self.eventDelegate orderBook:self hasNewEvent:theTrade];
}

-(void)socketController:(TTSocketController *)socketController settlementEventObserved:(NSDictionary *)eventData
{
    if (self.accountEventDelegate)
        [self.accountEventDelegate settlementEventObserved:eventData];
}

-(void)socketController:(TTSocketController *)socketController walletStateObserved:(NSDictionary *)walletDataDictionary
{
    if (self.accountEventDelegate)
        [self.accountEventDelegate walletStateObserved:walletDataDictionary];
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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSNumber* newState = [change objectForKey:@"new"];
    switch (newState.integerValue) {
        case 0:
            [self.eventDelegate orderBook:self hasNewConnectionState:(TTOrderBookConnectionStateNone)];
            break;
            
        case 1:
            [self.eventDelegate orderBook:self hasNewConnectionState:(TTOrderBookConnectionStateSocketDisconnected)];
            break;
            
        case 2:
            [self.eventDelegate orderBook:self hasNewConnectionState:(TTOrderBookConnectionStateSocketConnecting)];
            break;
            
        case 3:
            [self.eventDelegate orderBook:self hasNewConnectionState:(TTOrderBookConnectionStateSocketConnected)];
            break;
            
        case 4:
            [self.eventDelegate orderBook:self hasNewConnectionState:(TTOrderBookConnectionStateSocketUnavailable)];
            break;
            
        default:
            break;
    }
}

-(void)setWebsocket:(TTSocketController *)websocket
{
    [_websocket removeObserver:self forKeyPath:@"connectionState"];
    [self willChangeValueForKey:@"websocket"];
    _websocket = websocket;
    [self didChangeValueForKey:@"websocket"];
    [self.websocket addObserver:self forKeyPath:@"connectionState" options:NSKeyValueObservingOptionNew context:nil];
}

-(NSNumber *)localQuoteFromOrderBookSide:(TTOrderBookSide)side forQuantity:(NSNumber *)qty
{
    NSArray* arrayToExamine = nil;
    switch (side) {
        case TTOrderBookSideAsk:
            arrayToExamine = self.asks;
            break;
            
        case TTOrderBookSideBid:
            arrayToExamine = self.bids;
            break;
        
        case TTOrderBookSideNone:
        default:
            arrayToExamine = nil;
            break;
    }
    
    if (arrayToExamine)
    {
        __block NSInteger ordersIndex = 0;
        __block double cumulativeCost = 0;
        __block double cumulativeQuantity = 0;
        while (qty.doubleValue > cumulativeQuantity) {
            TTDepthOrder* order = [arrayToExamine objectAtIndex:ordersIndex];
            cumulativeQuantity = cumulativeQuantity + order.amount.doubleValue;
            cumulativeCost = cumulativeCost + (order.amount.floatValue * order.price.floatValue);
        }
//        if ()
//        {
        
//        }
    }
    return @0;
}

-(TTDepthOrder *)insideBuy
{
    @synchronized(self.bids)
    {
        return [self.bids lastObject];
    }
}

-(TTDepthOrder *)insideSell
{
    @synchronized(self.asks)
    {
        return [self.asks objectAtIndex:0];
    }
}

-(void)start
{
    if (self.websocket)
    {
        [self.websocket setDelegate:self];
    }
    else
        [self.eventDelegate orderBook:self hasNewConnectionState:TTOrderBookConnectionStateSocketUnavailable];
    
    [self.httpController getDepthForCurrency:self.currency withCompletion:^(NSArray *bids, NSArray *asks, NSDictionary *maxMinTicks) {
        
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
        
    }];
}



@end
