//
//  TTDepthOrder.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/13/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTDepthOrder : NSObject

@property(nonatomic, retain)NSNumber* amount;
@property(nonatomic, retain)NSNumber* price;
@property(nonatomic, retain)NSDate* time;

+(TTDepthOrder*)newDepthOrderFromDictionary:(NSDictionary*)dictionary;

@end
