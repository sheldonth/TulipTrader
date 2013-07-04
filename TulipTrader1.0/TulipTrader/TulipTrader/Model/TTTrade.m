//
//  TTTrade.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/3/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTTrade.h"
#import "TTCurrency.h"
#import "RUClassOrNilUtil.h"

@implementation TTTrade

+(TTTrade*)newTradeFromDictionary:(NSDictionary*)d
{
    TTTrade* t = [TTTrade new];
    NSDictionary* tradeDictionary = [d objectForKey:@"trade"];
    NSNumberFormatter* numberFormatter = [NSNumberFormatter new];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber* result = [numberFormatter numberFromString:[tradeDictionary objectForKey:@"tid"]];
    [t setTradeId:result];
    [t setCurrency:numberFromCurrencyString([tradeDictionary objectForKey:@"price_currency"])];
    [t setAmount:[tradeDictionary objectForKey:@"amount"]];
    [t setAmountInt:[kRUStringOrNil([tradeDictionary objectForKey:@"amount_int"]) integerValue]];
    [t setPrice:kRUNumberOrNil([tradeDictionary objectForKey:@"price"])];
    [t setPriceInt:[kRUStringOrNil([tradeDictionary objectForKey:@"price_int"]) integerValue]];
    [t setDate:[NSDate dateWithTimeIntervalSince1970:[[tradeDictionary objectForKey:@"date"]doubleValue]]];
    if ([[tradeDictionary objectForKey:@"primary"] isEqualToString:@"Y"])
        [t setReal_boolean:@(1)];
    else if ([[tradeDictionary objectForKey:@"primary"] isEqualToString:@"N"])
        [t setReal_boolean:@(0)];
    [t setProperties:kRUStringOrNil([d objectForKey:@"properties"])];
    NSString* tradeTypeStr = [tradeDictionary objectForKey:@"trade_type"];
    if ([tradeTypeStr isEqualToString:@"bid"])
        [t setTrade_type:(TTTradeTypeBid)];
    else if ([tradeTypeStr isEqualToString:@"ask"])
        [t setTrade_type:(TTTradeTypeAsk)];
    else
        [t setTrade_type:(TTTradeTypeNone)];
    return t;
}

@end
