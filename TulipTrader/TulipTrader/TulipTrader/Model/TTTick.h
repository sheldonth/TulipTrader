//
//  TTTick.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/21/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTTick : NSObject

@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) NSString * display;
@property (nonatomic, retain) NSString * display_short;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSNumber * value_int;
@property (nonatomic, retain) NSDate* timeStamp;

+(TTTick*)newTickfromDictionary:(NSDictionary*)d;

@end