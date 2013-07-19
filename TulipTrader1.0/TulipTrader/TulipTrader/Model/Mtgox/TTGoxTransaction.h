//
//  TTGoxTransaction.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/6/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTTick.h"
#import "TTGoxTransactionTrade.h"

@interface TTGoxTransaction : NSObject

@property(nonatomic, retain)TTTick* balance;
@property(nonatomic, retain)NSDate* date;
@property(nonatomic, retain)NSNumber* index;
@property(nonatomic, retain)NSString* infoString;
@property(nonatomic, retain)NSArray* linkArray;
@property(nonatomic, retain)NSString* type;
@property(nonatomic, retain)TTGoxTransactionTrade* trade;
@property(nonatomic, retain)TTTick* value;

+(TTGoxTransaction*)transactionFromDictionary:(NSDictionary*)d;

@end
