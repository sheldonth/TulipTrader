//
//  Trade.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/13/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Trade : NSManagedObject

@property (nonatomic, retain) NSNumber * tradeId;
@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * real_boolean;
@property (nonatomic, retain) NSString * trade_type;
@property (nonatomic, retain) NSString * properties;

+(Trade*)newNetworkTradeInContext:(NSManagedObjectContext*)context fromDictionary:(NSDictionary*)d;
+(Trade*)newDatabaseTradeInContext:(NSManagedObjectContext*)context fromDictionary:(NSDictionary*)d;
+(void)computeFunctionNamed:(NSString*)functionName onTradePropertyWithName:(NSString*)propertyName completion:(void (^)(NSNumber* computedResult))callbackBlock;
@end
