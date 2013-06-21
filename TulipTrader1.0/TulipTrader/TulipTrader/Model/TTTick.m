//
//  TTTick.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/21/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTTick.h"
#import "TTCurrency.h"
#import "RUClassOrNilUtil.h"

@implementation TTTick

+(TTTick*)newTickfromDictionary:(NSDictionary*)d
{
    TTTick* t = [TTTick new];
    [t setCurrency:numberFromCurrencyString(kRUStringOrNil([d objectForKey:@"currency"]))];
    [t setDisplay:kRUStringOrNil([d objectForKey:@"display"])];
    [t setDisplay_short:kRUStringOrNil([d objectForKey:@"display_short"])];
    [t setValue:@([kRUStringOrNil([d objectForKey:@"value"]) doubleValue])];
    [t setValue_int:@([kRUStringOrNil([d objectForKey:@"value_int"]) intValue])];
    [t setTimeStamp:[NSDate date]];
    return t;
}

@end