//
//  Ticker.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/18/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tick;

@interface Ticker : NSManagedObject

@property (nonatomic, retain) NSString * channel_id;
@property (nonatomic, retain) NSString * channel_name;
@property (nonatomic, retain) NSDate * now;
@property (nonatomic, retain) Tick *average;
@property (nonatomic, retain) Tick *buy;
@property (nonatomic, retain) Tick *high;
@property (nonatomic, retain) Tick *last;
@property (nonatomic, retain) Tick *last_all;
@property (nonatomic, retain) Tick *last_local;
@property (nonatomic, retain) Tick *last_orig;
@property (nonatomic, retain) Tick *low;
@property (nonatomic, retain) Tick *sell;
@property (nonatomic, retain) Tick *vol;
@property (nonatomic, retain) Tick *vwap;

+(NSManagedObject*)newTickerInContext:(NSManagedObjectContext*)context fromDictionary:(NSDictionary*)d;

@end


