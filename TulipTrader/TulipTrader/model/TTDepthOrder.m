//
//  TTDepthOrder.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/13/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

/*
 This class represents a delta to a limit orderbook. It will have various constructors for each market provider.
 However, it's end goal will remain the same: To change an orderbook by an atomic quantity.
 */

#import "TTDepthOrder.h"
#import "RUConstants.h"
#import "RUClassOrNilUtil.h"

@implementation TTDepthOrder

-(NSString *)description
{
    return RUStringWithFormat(@"%@ %@ at %@",stringFromCurrency(self.currency), self.amount, self.price);
}

-(BOOL)isAbsoluteTermsEqualToDepthOrder:(TTDepthOrder*)depthOrder consideringTimestampString:(BOOL)considers
{
    if ([self.amount isEqualToNumber:@(fabsf(depthOrder.amount.floatValue))] && [self.price isEqualToNumber:@(fabsf(depthOrder.price.floatValue))])
    {
        if (considers)
        {
            if ([self.timeStampStr isEqualToString:depthOrder.timeStampStr])
                return YES;
            else
                return NO;
        }
        return YES;
    }
    else
        return NO;
}

-(BOOL)isAbsoluteTermsEqualToDepthOrder:(TTDepthOrder*)depthOrder
{
    return [self isAbsoluteTermsEqualToDepthOrder:depthOrder consideringTimestampString:NO];
}

+(TTDepthOrder*)newDepthOrderFromGoxWebsocketDictionary:(NSDictionary*)d
{
    TTDepthOrder* deltaOrder = [TTDepthOrder new];
    [deltaOrder setAmount:@(kRUStringOrNil([d objectForKey:@"volume"]).doubleValue)];
    [deltaOrder setPrice:@(kRUStringOrNil([d objectForKey:@"price"]).doubleValue)];
    
    NSString* microsecondTimeString = [d objectForKey:@"now"];
    [deltaOrder setTime:[NSDate dateWithTimeIntervalSince1970:(microsecondTimeString.doubleValue / 1000000)]];
    [deltaOrder setTimeStampStr:[d objectForKey:@"now"]];
    
    NSString* typeStr = [d objectForKey:@"type_str"];
    
    if ([typeStr isEqualToString:@"ask"])
        [deltaOrder setDepthOrderType:(TTDepthOrderTypeAsk)];
    else if ([typeStr isEqualToString:@"bid"])
        [deltaOrder setDepthOrderType:(TTDepthOrderTypeBid)];
    else
        [deltaOrder setDepthOrderType:(TTDepthOrderTypeNone)];
    
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
    return d;
}

@end
