//
//  TTDepthOrder.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/13/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    TTDepthOrderTypeNone = 0,
    TTDepthOrderTypeBid,
    TTDepthOrderTypeAsk
}TTDepthOrderType;

@interface TTDepthOrder : NSObject

@property(nonatomic, retain)NSNumber* amount;
@property(nonatomic, retain)NSNumber* price;
@property(nonatomic, retain)NSDate* time;
@property(nonatomic, retain)NSString* timeStampStr;

// Optional, defaults to none
@property(nonatomic)TTDepthOrderType depthOrderType;

-(BOOL)isAbsoluteTermsEqualToDepthOrder:(TTDepthOrder*)depthOrder consideringTimestampString:(BOOL)considers;
-(BOOL)isAbsoluteTermsEqualToDepthOrder:(TTDepthOrder*)depthOrder;

+(TTDepthOrder*)newDepthOrderFromDictionary:(NSDictionary*)dictionary;

@end
