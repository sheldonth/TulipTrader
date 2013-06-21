//
//  TTDepthOrder.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/13/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTGoxCurrency.h"

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

@property(nonatomic)TTGoxCurrency currency;

// Optional, defaults to none
@property(nonatomic)TTDepthOrderType depthOrderType;
@property(nonatomic)TTDepthOrderAction* depthOrderAction;

-(BOOL)isAbsoluteTermsEqualToDepthOrder:(TTDepthOrder*)depthOrder consideringTimestampString:(BOOL)considers;
-(BOOL)isAbsoluteTermsEqualToDepthOrder:(TTDepthOrder*)depthOrder;

+(TTDepthOrder*)newDepthOrderFromGOXHTTPDictionary:(NSDictionary*)dictionary;
+(TTDepthOrder*)newDepthOrderFromGoxWebsocketDictionary:(NSDictionary*)d;

@end
