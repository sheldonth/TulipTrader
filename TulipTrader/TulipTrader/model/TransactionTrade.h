//
//  TransactionTrade.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/6/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tick.h"

@interface TransactionTrade : NSObject

@property(nonatomic, retain)InMemoryTick* amount;
@property(nonatomic, retain)NSString* properties;
@property(nonatomic, retain)NSString* app;
@property(nonatomic, retain)NSString* oid;
@property(nonatomic, retain)NSString* tid;

@end
