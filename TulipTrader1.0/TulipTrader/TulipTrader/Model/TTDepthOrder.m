//
//  TTDepthOrder.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/21/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTDepthOrder.h"
#import "RUConstants.h"
#import "RUClassOrNilUtil.h"

@implementation TTDepthOrder

-(NSString *)description
{
    return RUStringWithFormat(@"%@ %@ at %@",stringFromCurrency(self.currency), self.amount, self.price);
}

+(TTDepthOrder*)newDepthOrderFromGoxWebsocketDictionary:(NSDictionary*)d
{
    TTDepthOrder* deltaOrder = [TTDepthOrder new];
    [deltaOrder setAmount:@(kRUStringOrNil([d objectForKey:@"volume"]).doubleValue)];
    [deltaOrder setPrice:@(kRUStringOrNil([d objectForKey:@"price"]).doubleValue)];
    [deltaOrder setPriceInt:[kRUStringOrNil([d objectForKey:@"price_int"]) integerValue]];
    
    if (deltaOrder.amount.floatValue < 0)
    {
        [deltaOrder setDepthDeltaAction:TTDepthOrderActionRemove];
        [deltaOrder setAmount:@(fabsf(deltaOrder.amount.floatValue))];
        [deltaOrder setAmountInt:ABS([kRUStringOrNil([d objectForKey:@"volume_int"])integerValue])];
    }
    else if (deltaOrder.amount.floatValue > 0)
    {
        [deltaOrder setAmountInt:[kRUStringOrNil([d objectForKey:@"volume_int"])integerValue]];
        [deltaOrder setDepthDeltaAction:TTDepthOrderActionAdd];
    }
    
    NSString* microsecondTimeString = [d objectForKey:@"now"];
    [deltaOrder setTime:[NSDate dateWithTimeIntervalSince1970:(microsecondTimeString.doubleValue / 1000000)]];
    [deltaOrder setTimeStampStr:[d objectForKey:@"now"]];
    
    NSString* typeStr = [d objectForKey:@"type_str"];
    
    if ([typeStr isEqualToString:@"ask"])
        [deltaOrder setDepthDeltaType:(TTDepthOrderTypeAsk)];
    else if ([typeStr isEqualToString:@"bid"])
        [deltaOrder setDepthDeltaType:(TTDepthOrderTypeBid)];
    else
        [deltaOrder setDepthDeltaType:(TTDepthOrderTypeNone)];
    
    [deltaOrder setCurrency:currencyFromString([d objectForKey:@"currency"])];
    
    return deltaOrder;
}

+(TTDepthOrder*)newDepthOrderFromGOXHTTPDictionary:(NSDictionary*)dictionary;
{
    TTDepthOrder* d = [TTDepthOrder new];
    [d setAmount:[dictionary objectForKey:@"amount"]];
    [d setPrice:[dictionary objectForKey:@"price"]];
    NSString* microsecondTimeString = [dictionary objectForKey:@"stamp"];
    [d setTime:[NSDate dateWithTimeIntervalSince1970:(microsecondTimeString.doubleValue / 1000000)]];
    [d setTimeStampStr:[dictionary objectForKey:@"stamp"]];
    [d setAmountInt:[kRUStringOrNil([dictionary objectForKey:@"amount_int"])integerValue]];
    [d setPriceInt:[kRUStringOrNil([dictionary objectForKey:@"price_int"]) integerValue]];
    return d;
}


@end
