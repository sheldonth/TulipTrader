//
//  TTGoxPrivateMessageController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/1/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "TTGoxPrivateMessageController.h"
#import "TTGoxSocketController.h"
#import "RUSingleton.h"
#import "RUConstants.h"
#import "Ticker.h"
#import "TTAppDelegate.h"
#import "Tick.h"
#import "Trade.h"
#import "TTAPIControlBoxView.h"

#define NOISYTRADES 1

typedef enum{
    kTTGoxMarketNone = 0,
    kTTGoxMarketDepth = 1,
    kTTGoxMarketTrade = 2,
    kTTGoxMarketTicker = 3,
    kTTGoxMarketLag = 4
}kTTGoxMarketDataType;

NSString* const kTTGoxDepthKey = @"depth";
NSString* const kTTGoxTickerKey = @"ticker";
NSString* const kTTGoxTradeKey = @"trade";
NSString* const kTTGoxLagKey = @"lag";

static NSManagedObjectContext* primaryContext;
static dispatch_queue_t privateMessageOperationQueue;

NSString* const TTGoxWebsocketTickerNotificationString = @"ttGoxTickerUpdateNotification";
NSString* const TTGoxWebsocketTradeNotificationString = @"ttGoxTradeUpdateNotification";
NSString* const TTGoxWebsocketLagUpdateNotificationString = @"ttGoxLagUpdateNotification";
NSString* const TTGoxWebsocketDepthNotificationString = @"ttGoxDepthUpdateNotification";

@implementation TTGoxPrivateMessageController

+(void)initialize
{
    primaryContext = [(TTAppDelegate*)[[NSApplication sharedApplication]delegate]managedObjectContext];
    privateMessageOperationQueue = dispatch_queue_create("PrivateMessageController", NULL);
}

-(void)recordDepth:(NSDictionary*)depthDictionary
{
    if (self.depthDelegate && [self.depthDelegate respondsToSelector:@selector(depthChangeObserved:)])
        [self.depthDelegate depthChangeObserved:depthDictionary];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:TTGoxWebsocketDepthNotificationString object:nil userInfo:@{@"DepthDictionary": depthDictionary}];
}

-(void)recordTrade:(NSDictionary*)tradeDictionary
{
    NSManagedObjectContext* c = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [c setPersistentStoreCoordinator:primaryContext.persistentStoreCoordinator];
    Trade* trade = [Trade newNetworkTradeInContext:c fromDictionary:[tradeDictionary objectForKey:@"trade"]];
    [c performBlockAndWait:^{
        NSError* e = nil;
        [c save:&e];
        if (e)
            RUDLog(@"Error saving Trade");
        else
        {
            if (NOISYTRADES)
            {
                if ([trade.trade_type isEqualToString:@"bid"])
                    [TTAPIControlBoxView publishCommand:RUStringWithFormat(@"%@BTC bought for %@ %@ (%@)", trade.amount.stringValue, stringFromCurrency(currencyFromNumber(trade.currency)), trade.price.stringValue, trade.properties)];
                else
                    [TTAPIControlBoxView publishCommand:RUStringWithFormat(@"%@BTC sold for %@ %@ (%@)", trade.amount.stringValue, stringFromCurrency(currencyFromNumber(trade.currency)), trade.price.stringValue, trade.properties)];
            }
        }
    }];
    if (self.tradeDelegate && [self.tradeDelegate respondsToSelector:@selector(tradeOccuredForCurrency:tradeData:)])
        [self.tradeDelegate tradeOccuredForCurrency:currencyFromNumber(trade.currency) tradeData:trade];
    [[NSNotificationCenter defaultCenter]postNotificationName:TTGoxWebsocketTradeNotificationString object:self userInfo:@{@"Trade": trade}];
}

-(void)recordTicker:(NSDictionary*)tickerDictionary
{
    NSManagedObjectContext* c = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [c setPersistentStoreCoordinator:primaryContext.persistentStoreCoordinator];
    Ticker* ticker = [Ticker newTickerInContext:c fromDictionary:tickerDictionary];
    [ticker.managedObjectContext performBlockAndWait:^{
        NSError* e = nil;
        [ticker.managedObjectContext save:&e];
        if (e)
            RUDLog(@"Error saving ticker on channel: %@", ticker.channel_name);
    }];
    if (self.tickerDelegate && [self.tickerDelegate respondsToSelector:@selector(tickerObserved:forChannel:)])
        [self.tickerDelegate tickerObserved:ticker forChannel:ticker.channel_id];
        
    [[NSNotificationCenter defaultCenter]postNotificationName:TTGoxWebsocketTickerNotificationString object:self userInfo:@{@"Ticker": ticker}];
}

-(void)observeLag:(NSDictionary*)lagDictionary
{
    if (self.lagDelegate && [self.lagDelegate respondsToSelector:@selector(lagObserved:)])
        [_lagDelegate lagObserved:lagDictionary];
    else
        [[NSNotificationCenter defaultCenter]postNotificationName:TTGoxWebsocketLagUpdateNotificationString object:self userInfo:@{@"lagDictionary": lagDictionary}];
}

-(void)shouldExamineMarketDataDictionary:(NSDictionary *)dictionary
{
    kTTGoxMarketDataType dataType =  TTGoxPrivateMessageControllerDataType([dictionary objectForKey:@"private"]);
    switch (dataType) {
        case kTTGoxMarketDepth:
            [self recordDepth:dictionary];
            break;
            
        case kTTGoxMarketTrade:
            [self recordTrade:dictionary];
            break;
            
        case kTTGoxMarketTicker:
            [self recordTicker:dictionary];
            break;
            
        case kTTGoxMarketLag:
            [self observeLag:dictionary];
            break;
            
        case kTTGoxMarketNone:
            RUDLog(@"Market Message of Type kTTGoxMarketNone");
            break;
            
        default:
            break;
    }
    
}

kTTGoxMarketDataType TTGoxPrivateMessageControllerDataType(NSString* typeString)
{
    if ([typeString isEqualToString:kTTGoxDepthKey])
        return kTTGoxMarketDepth;
    else if ([typeString isEqualToString:kTTGoxTickerKey])
        return kTTGoxMarketTicker;
    else if ([typeString isEqualToString:kTTGoxTradeKey])
        return kTTGoxMarketTrade;
    else if ([typeString isEqualToString:kTTGoxLagKey])
        return kTTGoxMarketLag;
    else
        return kTTGoxMarketNone;
}

@end
