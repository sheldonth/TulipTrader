//
//  TTGoxTransactionTrade.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/18/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TTTick.h"

@interface TTGoxTransactionTrade : NSObject

@property(nonatomic, retain)TTTick* amount;
@property(nonatomic, retain)NSString* properties;
@property(nonatomic, retain)NSString* app;
@property(nonatomic, retain)NSString* oid;
@property(nonatomic, retain)NSString* tid;

+(TTGoxTransactionTrade*)newTransactionTradeFromDictionary:(NSDictionary*)d;

@end
