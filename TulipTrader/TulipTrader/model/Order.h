//
//  Order.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/3/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tick.h"
#import "TTGoxCurrency.h"

typedef enum{
    TTGoxOrderStatusNone = 0,
    TTGoxOrderStatusPending,
    TTGoxOrderStatusExecuting,
    TTGoxOrderStatusPostPending,
    TTGoxOrderStatusOpen,
    TTGoxOrderStatusStop,
    TTGoxOrderStatusInvalid
}TTGoxOrderStatus;

typedef enum{
    TTGoxOrderTypeNone = 0,
    TTGoxOrderTypeBid,
    TTGoxOrderTypeAsk
}TTGoxOrderType;

@interface Order : NSObject

@property(nonatomic, retain)InMemoryTick* amount;
@property(nonatomic)TTGoxCurrency currency;
@property(nonatomic, retain)NSDate* timestamp;
@property(nonatomic, retain)NSString* item;
@property(nonatomic, retain)NSString* oid;
@property(nonatomic, retain)InMemoryTick* price;
@property(nonatomic, retain)NSNumber* priorityNumber;
@property(nonatomic)TTGoxOrderStatus orderStatus;
@property(nonatomic)TTGoxOrderType orderType;

+(Order*)newOrderFromDictionary:(NSDictionary*)d;

NSString* stringFromOrderStatus(TTGoxOrderStatus status);

@end

