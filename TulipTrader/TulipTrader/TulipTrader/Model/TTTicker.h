//
//  TTTicker.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/21/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTTick.h"

@interface TTTicker : NSObject

@property (nonatomic, retain) NSString * channel_id;
@property (nonatomic, retain) NSString * channel_name;
@property (nonatomic, retain) NSDate * now;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) TTTick *average;
@property (nonatomic, retain) TTTick *buy;
@property (nonatomic, retain) TTTick *high;
@property (nonatomic, retain) TTTick *last;
@property (nonatomic, retain) TTTick *last_all;
@property (nonatomic, retain) TTTick *last_local;
@property (nonatomic, retain) TTTick *last_orig;
@property (nonatomic, retain) TTTick *low;
@property (nonatomic, retain) TTTick *sell;
@property (nonatomic, retain) TTTick *vol;
@property (nonatomic, retain) TTTick *vwap;

+(TTTicker*)newTickerFromDictionary:(NSDictionary*)d;

@end
