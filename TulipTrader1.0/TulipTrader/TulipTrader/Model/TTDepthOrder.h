//
//  TTDepthOrder.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/21/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTCurrency.h"

typedef enum{
    TTDepthOrderTypeNone = 0,
    TTDepthOrderTypeBid,
    TTDepthOrderTypeAsk
}TTDepthOrderType;

typedef enum{
    TTDepthOrderActionNone = 0,
    TTDepthOrderActionAdd,
    TTDepthOrderActionRemove,
}TTDepthOrderAction;

@interface TTDepthOrder : NSObject

@property(nonatomic, retain)NSNumber* amount;
@property(nonatomic, retain)NSNumber* price;
@property(nonatomic, retain)NSDate* time;
@property(nonatomic, retain)NSString* timeStampStr;

@property(nonatomic)NSInteger amountInt;
@property(nonatomic)NSInteger priceInt;

@property(nonatomic)TTCurrency currency;

// Optional, defaults to none
@property(nonatomic)TTDepthOrderType depthDeltaType;
@property(nonatomic)TTDepthOrderAction depthDeltaAction;

// Various Constructors For Different Webservice Configs

+(TTDepthOrder*)newDepthOrderFromGOXHTTPDictionary:(NSDictionary*)dictionary;
+(TTDepthOrder*)newDepthOrderFromGoxWebsocketDictionary:(NSDictionary*)d;

@end
