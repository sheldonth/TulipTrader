//
//  Ticker.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/18/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "Ticker.h"
#import "Tick.h"


@implementation Ticker

@dynamic channel_id;
@dynamic channel_name;
@dynamic now;
@dynamic average;
@dynamic buy;
@dynamic high;
@dynamic last;
@dynamic last_all;
@dynamic last_local;
@dynamic last_orig;
@dynamic low;
@dynamic sell;
@dynamic vol;
@dynamic vwap;

+(Ticker*)newTickerInContext:(NSManagedObjectContext*)context fromDictionary:(NSDictionary*)d
{
    Ticker* t = [NSEntityDescription insertNewObjectForEntityForName:@"Ticker" inManagedObjectContext:context];
    [t setChannel_name:[d objectForKey:@"channel_name"]];
    NSDictionary* tickTypes = [d objectForKey:@"ticker"];
    [t setAverage:[Tick newTickInContext:context fromDictionary:[tickTypes objectForKey:@"avg"]]];
    return t;
}

@end
