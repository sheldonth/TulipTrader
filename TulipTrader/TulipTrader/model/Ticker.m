//
//  Ticker.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/18/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "Ticker.h"
#import "Tick.h"
#import "RUClassOrNilUtil.h"

@implementation Ticker

@dynamic channel_id;
@dynamic channel_name;
@dynamic now;
@dynamic timeStamp;
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

#define OneMillion 1000000.f

+(Ticker*)newTickerInContext:(NSManagedObjectContext*)context fromDictionary:(NSDictionary*)d
{
    Ticker* t = [NSEntityDescription insertNewObjectForEntityForName:@"Ticker" inManagedObjectContext:context];
    
    [t setChannel_name:kRUStringOrNil([d objectForKey:@"channel_name"])];
    
    [t setChannel_id:kRUStringOrNil([d objectForKey:@"channel"])];
    
    [t setTimeStamp:[NSDate date]];
    
    NSDictionary* tickTypes = [d objectForKey:@"ticker"];
    
    NSString* timeStampInMillionthsString = [tickTypes objectForKey:@"now"];
    
    double timeStampInMillionthsDouble = timeStampInMillionthsString.doubleValue;
    
    NSTimeInterval timeIntervalInSeconds = timeStampInMillionthsDouble / OneMillion;
    
    [t setNow:[NSDate dateWithTimeIntervalSince1970:timeIntervalInSeconds]];
    
    [t setAverage:[Tick newTickInContext:context fromDictionary:[tickTypes objectForKey:@"avg"]]];
    [t setBuy:[Tick newTickInContext:context fromDictionary:[tickTypes objectForKey:@"buy"]]];
    [t setHigh:[Tick newTickInContext:context fromDictionary:[tickTypes objectForKey:@"high"]]];
    [t setLast:[Tick newTickInContext:context fromDictionary:[tickTypes objectForKey:@"last"]]];
    [t setLast_all:[Tick newTickInContext:context fromDictionary:[tickTypes objectForKey:@"last_all"]]];
    [t setLast_local:[Tick newTickInContext:context fromDictionary:[tickTypes objectForKey:@"last_local"]]];
    [t setLast_orig:[Tick newTickInContext:context fromDictionary:[tickTypes objectForKey:@"last_orig"]]];
    [t setLow:[Tick newTickInContext:context fromDictionary:[tickTypes objectForKey:@"low"]]];
    [t setSell:[Tick newTickInContext:context fromDictionary:[tickTypes objectForKey:@"sell"]]];
    [t setVol:[Tick newTickInContext:context fromDictionary:[tickTypes objectForKey:@"vol"]]];
    [t setVwap:[Tick newTickInContext:context fromDictionary:[tickTypes objectForKey:@"vwap"]]];
    
    return t;
}

@end
