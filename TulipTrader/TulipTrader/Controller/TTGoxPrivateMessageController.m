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

typedef enum{
    kTTGoxMarketNone = 0,
    kTTGoxMarketDepth = 1,
    kTTGoxMarketTrade = 2,
    kTTGoxMarketTicker = 3
}kTTGoxMarketDataType;

NSString* const kTTGoxDepthKey = @"depth";
NSString* const kTTGoxTickerKey = @"ticker";
NSString* const kTTGoxTradeKey = @"trade";

static NSManagedObjectContext* primaryContext;

@implementation TTGoxPrivateMessageController

+(void)initialize
{
    primaryContext = [(TTAppDelegate*)[[NSApplication sharedApplication]delegate]managedObjectContext];
}

-(void)recordDepth:(NSDictionary*)depthDictionary
{
    RUDLog(@"!");
}

-(void)recordTrade:(NSDictionary*)tradeDictionary
{
    RUDLog(@"!");
}

-(void)recordTicker:(NSDictionary*)tickerDictionary
{
    RUDLog(@"!");
    Ticker* ticker = [Ticker newTickerInContext:primaryContext fromDictionary:tickerDictionary];
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
    else
        return kTTGoxMarketNone;
}

RU_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(TTGoxPrivateMessageController, sharedInstance);

@end
