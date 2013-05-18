//
//  TTGoxPrivateMessageController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/1/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "TTGoxPrivateMessageController.h"
#import "TTGoxSocketController.h"
#import "RUSingleton.h"
#import "RUConstants.h"
#import "Ticker.h"
#import "TTAppDelegate.h"
#import "Tick.h"

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

NSString* const TTCurrencyUpdateNotificationString = @"ttCurrencyUpdateNotification";

@implementation TTGoxPrivateMessageController

+(void)initialize
{
    primaryContext = [(TTAppDelegate*)[[NSApplication sharedApplication]delegate]managedObjectContext];
}

-(void)recordDepth:(NSDictionary*)depthDictionary
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // do depth stuff here
    });
}

-(void)recordTrade:(NSDictionary*)tradeDictionary
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // do trade stuff here
    });
}

-(void)recordTicker:(NSDictionary*)tickerDictionary
{
    dispatch_async(dispatch_get_main_queue(), ^{
        Ticker* ticker = [Ticker newTickerInContext:primaryContext fromDictionary:tickerDictionary];
        NSError* e = nil;
        [ticker.managedObjectContext save:&e];
        if (e)
            RUDLog(@"Error saving ticker on channel: %@", ticker.channel_name);
        [[NSNotificationCenter defaultCenter]postNotificationName:TTCurrencyUpdateNotificationString object:nil userInfo:@{@"Ticker": ticker}];
    });
}

-(void)observeLag:(NSDictionary*)lagDictionary
{
    if (self.lagDelegate && [self.lagDelegate respondsToSelector:@selector(lagObserved:)])
        [_lagDelegate lagObserved:lagDictionary];
}

-(void)shouldExamineResponseDictionary:(NSDictionary *)dictionary ofMessageType:(TTGoxSocketMessageType)type
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

RU_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(TTGoxPrivateMessageController, sharedInstance);

@end
