//
//  TTDepthOrder.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/13/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTDepthOrder.h"
#import "RUConstants.h"

@implementation TTDepthOrder

-(NSString *)description
{
    return RUStringWithFormat(@"%@ at %@", self.amount, self.price);
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

+(TTDepthOrder*)newDepthOrderFromDictionary:(NSDictionary*)dictionary
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
