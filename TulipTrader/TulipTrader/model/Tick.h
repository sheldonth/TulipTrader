//
//  Tick.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/18/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Tick : NSManagedObject

@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) NSString * display;
@property (nonatomic, retain) NSString * display_short;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSNumber * value_int;

+(Tick*)newTickInContext:(NSManagedObjectContext*)context fromDictionary:(NSDictionary*)d;

@end
