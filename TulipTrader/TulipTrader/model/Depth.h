//
//  Depth.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/18/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Depth : NSManagedObject

@property (nonatomic, retain) NSString * channel_name;
@property (nonatomic, retain) NSString * channel_id;
@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSString * item;
@property (nonatomic, retain) NSDate * now;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * price_int;
@property (nonatomic, retain) NSNumber * total_volume_int;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * type_str;
@property (nonatomic, retain) NSNumber * volume;
@property (nonatomic, retain) NSNumber * volume_int;

@end
