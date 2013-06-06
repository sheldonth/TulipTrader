//
//  Transaction.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/6/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tick.h"
#import "TransactionTrade.h"

@interface Transaction : NSObject

@property(nonatomic, retain)InMemoryTick* balance;
@property(nonatomic, retain)NSDate* date;
@property(nonatomic, retain)NSNumber* index;
@property(nonatomic, retain)NSString* infoString;
@property(nonatomic, retain)NSArray* linkArray;
@property(nonatomic, retain)NSString* type;
@property(nonatomic, retain)TransactionTrade* trade;
@property(nonatomic, retain)InMemoryTick* value;

+(Transaction*)transactionFromDictionary:(NSDictionary*)d;

@end
