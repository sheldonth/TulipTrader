//
//  TTTicker.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/21/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTTicker.h"
#import "RUClassOrNilUtil.h"
#import "TTTick.h"

#define OneMillion 1000000.f

@implementation TTTicker

+(TTTicker*)newTickerFromDictionary:(NSDictionary*)d
{
    TTTicker* t = [TTTicker new];
    
    [t setChannel_name:kRUStringOrNil([d objectForKey:@"channel_name"])];
    
    [t setChannel_id:kRUStringOrNil([d objectForKey:@"channel"])];
    
    [t setTimeStamp:[NSDate date]];
    
    NSDictionary* tickTypes = [d objectForKey:@"ticker"];
    
    NSString* timeStampInMillionthsString = [tickTypes objectForKey:@"now"];
    
    double timeStampInMillionthsDouble = timeStampInMillionthsString.doubleValue;
    
    NSTimeInterval timeIntervalInSeconds = timeStampInMillionthsDouble / OneMillion;
    
    [t setNow:[NSDate dateWithTimeIntervalSince1970:timeIntervalInSeconds]];
    
    [t setAverage:[TTTick newTickfromDictionary:[tickTypes objectForKey:@"avg"]]];
    [t setBuy:[TTTick newTickfromDictionary:[tickTypes objectForKey:@"buy"]]];
    [t setHigh:[TTTick newTickfromDictionary:[tickTypes objectForKey:@"high"]]];
    [t setLast:[TTTick newTickfromDictionary:[tickTypes objectForKey:@"last"]]];
    [t setLast_all:[TTTick newTickfromDictionary:[tickTypes objectForKey:@"last_all"]]];
    [t setLast_local:[TTTick newTickfromDictionary:[tickTypes objectForKey:@"last_local"]]];
    [t setLast_orig:[TTTick newTickfromDictionary:[tickTypes objectForKey:@"last_orig"]]];
    [t setLow:[TTTick newTickfromDictionary:[tickTypes objectForKey:@"low"]]];
    [t setSell:[TTTick newTickfromDictionary:[tickTypes objectForKey:@"sell"]]];
    [t setVol:[TTTick newTickfromDictionary:[tickTypes objectForKey:@"vol"]]];
    [t setVwap:[TTTick newTickfromDictionary:[tickTypes objectForKey:@"vwap"]]];
    
    return t;
}


@end
