//
//  Order.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/3/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

/*
 A limit order to buy or sell bitcoin in a given currency.
 */

#import "Order.h"
#import "RUConstants.h"

@implementation Order

NSString* stringFromOrderStatus(TTGoxOrderStatus status)
{
    NSString* retVal = nil;
    switch (status) {
        case TTGoxOrderStatusPending:
            retVal = @"Pending";
            break;
            
        case TTGoxOrderStatusExecuting:
            retVal = @"Executing";
            break;
            
        case TTGoxOrderStatusPostPending:
            retVal = @"Post-Pending";
            break;
            
        case TTGoxOrderStatusOpen:
            retVal = @"Open";
            break;
            
        case TTGoxOrderStatusStop:
            retVal = @"Stop";
            break;
            
        case TTGoxOrderStatusInvalid:
            retVal = @"Invalid";
            break;
        
        case TTGoxOrderStatusNone:
        default:
            retVal = @"ERR";
            break;
    }
    return retVal;
}

TTGoxOrderStatus orderStatusFromString(NSString* orderStatusString)
{
    if ([orderStatusString isEqualToString:@"pending"])
        return TTGoxOrderStatusPending;
    else if ([orderStatusString isEqualToString:@"executing"])
        return TTGoxOrderStatusExecuting;
    else if ([orderStatusString isEqualToString:@"post-pending"])
        return TTGoxOrderStatusPostPending;
    else if([orderStatusString isEqualToString:@"open"])
        return TTGoxOrderStatusOpen;
    else if([orderStatusString isEqualToString:@"stop"])
        return TTGoxOrderStatusStop;
    else if ([orderStatusString isEqualToString:@"invalid"])
        return TTGoxOrderStatusInvalid;
    else
        RUDLog(@"Unable to determine order status: %@", orderStatusString);
    return TTGoxOrderStatusNone;
}

TTGoxOrderType orderTypeFromString(NSString* orderTypeString)
{
    if ([orderTypeString isEqualToString:@"bid"])
        return TTGoxOrderTypeBid;
    else if([orderTypeString isEqualToString:@"ask"])
        return TTGoxOrderTypeAsk;
    else
        RUDLog(@"Failed To Determine Order Type: %@", orderTypeString);
    return TTGoxOrderTypeNone;
}

+(Order*)newOrderFromDictionary:(NSDictionary*)d
{
    Order* o =[Order new];
    [o setAmount:[InMemoryTick newInMemoryTickfromDictionary:[d objectForKey:@"amount"]]];
    [o setCurrency:currencyFromString([d objectForKey:@"currency"])];
    NSNumber* dateNumber = [d objectForKey:@"date"];
    [o setTimestamp:[NSDate dateWithTimeIntervalSince1970:dateNumber.doubleValue]];
    [o setItem:[d objectForKey:@"item"]];
    [o setOid:[d objectForKey:@"oid"]];
    [o setPrice:[InMemoryTick newInMemoryTickfromDictionary:[d objectForKey:@"price"]]];
    [o setPriorityNumber:[d objectForKey:@"priority"]];
    [o setOrderStatus:orderStatusFromString([d objectForKey:@"status"])];
    [o setOrderType:orderTypeFromString([d objectForKey:@"type"])];
    return o;
}

-(NSString *)description
{
    return RUStringWithFormat(@"oid: %@ timestamp: %f", self.oid, [self.timestamp timeIntervalSince1970]);
}

@end
