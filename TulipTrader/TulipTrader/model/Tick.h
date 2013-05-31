//
//  Tick.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/20/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tick : NSManagedObject

@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) NSString * display;
@property (nonatomic, retain) NSString * display_short;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSNumber * value_int;
@property (nonatomic, retain) NSDate* timeStamp;


+(Tick*)newTickInContext:(NSManagedObjectContext*)context fromDictionary:(NSDictionary*)d;

@end

@interface InMemoryTick : NSObject

@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) NSString * display;
@property (nonatomic, retain) NSString * display_short;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSNumber * value_int;
@property (nonatomic, retain) NSDate* timeStamp;

+(InMemoryTick*)newInMemoryTickfromDictionary:(NSDictionary*)d;

@end
