//
//  TTTrade.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/3/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    TTTradeTypeNone = 0,
    TTTradeTypeBid,
    TTTradeTypeAsk
}TTTradeType;

@interface TTTrade : NSObject

@property (nonatomic, retain) NSNumber * tradeId;
@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic) NSInteger amountInt;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic) NSInteger priceInt;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * real_boolean;
@property (nonatomic, retain) NSString * properties;

@property (nonatomic, retain) NSString* typeString;

@property (nonatomic) TTTradeType trade_type;

+(TTTrade*)newTradeFromDictionary:(NSDictionary*)d;

@end
