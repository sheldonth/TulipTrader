//
//  Trade.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/13/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "Trade.h"
#import "RUClassOrNilUtil.h"
#import "RUConstants.h"
#import "TTGoxCurrency.h"

@implementation Trade

@dynamic tradeId;
@dynamic currency;
@dynamic amount;
@dynamic price;
@dynamic date;
@dynamic real_boolean;
@dynamic trade_type;
@dynamic properties;

-(NSString *)description
{
    return RUStringWithFormat(@"Trade %@ in %@ for %@ at %@ and is real %@", self.tradeId.stringValue, stringFromCurrency(currencyFromNumber(self.currency)), self.amount.stringValue, self.price.stringValue, self.real_boolean.stringValue);
}

+(Trade*)newTradeInContext:(NSManagedObjectContext*)context fromDictionary:(NSDictionary*)d
{
    Trade* t = [NSEntityDescription insertNewObjectForEntityForName:@"Trade" inManagedObjectContext:context];
    [t setTradeId:kRUNumberOrNil([d objectForKey:@"tid"])];
    [t setCurrency:kRUNumberOrNil([d objectForKey:@"currency"])];
    [t setAmount:kRUNumberOrNil([d objectForKey:@"amount"])];
    [t setPrice:kRUNumberOrNil([d objectForKey:@"price"])];
    [t setDate:[NSDate dateWithTimeIntervalSince1970:[[d objectForKey:@"date"]doubleValue]]];
    if ([[d objectForKey:@"primary"] isEqualToString:@"Y"])
        [t setReal_boolean:@(1)];
    else if ([[d objectForKey:@"primary"] isEqualToString:@"N"])
        [t setReal_boolean:@(0)];
    [t setTrade_type:kRUStringOrNil([d objectForKey:@"trade_type"])];
    [t setProperties:kRUStringOrNil([d objectForKey:@"properties"])];
    return t;
}

@end
