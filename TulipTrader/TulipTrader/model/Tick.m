//
//  Tick.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/18/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "Tick.h"


@implementation Tick

@dynamic currency;
@dynamic display;
@dynamic display_short;
@dynamic value;
@dynamic value_int;

+(Tick*)newTickInContext:(NSManagedObjectContext*)context fromDictionary:(NSDictionary*)d
{
    Tick* t = [NSEntityDescription insertNewObjectForEntityForName:@"Tick" inManagedObjectContext:context];
    [t setCurrency:[d objectForKey:@"currency"]];
    
}

@end
