//
//  Tick.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/20/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "Tick.h"
#import "RUClassOrNilUtil.h"
#import "TTGoxCurrency.h"

@implementation Tick

@dynamic currency;
@dynamic display;
@dynamic display_short;
@dynamic value;
@dynamic value_int;
@dynamic timeStamp;

+(Tick*)newTickInContext:(NSManagedObjectContext*)context fromDictionary:(NSDictionary*)d
{
    Tick* t = [NSEntityDescription insertNewObjectForEntityForName:@"Tick" inManagedObjectContext:context];
    [t setCurrency:numberFromCurrencyString(kRUStringOrNil([d objectForKey:@"currency"]))];
    [t setDisplay:kRUStringOrNil([d objectForKey:@"display"])];
    [t setDisplay_short:kRUStringOrNil([d objectForKey:@"display_short"])];
    [t setValue:@([kRUStringOrNil([d objectForKey:@"value"]) doubleValue])];
    [t setValue_int:@([kRUStringOrNil([d objectForKey:@"value_int"]) intValue])];
    [t setTimeStamp:[NSDate date]];
    return t;
}

@end
