//
//  TTGoxWallet.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/31/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTGoxCurrency.h"
#import "Tick.h"

@interface TTGoxWallet : NSObject

@property(nonatomic)TTGoxCurrency currency;
@property(nonatomic, retain)InMemoryTick* balance;
@property(nonatomic, retain)InMemoryTick* dailyWithdrawalLimit;
@property(nonatomic, retain)InMemoryTick* maxWithdraw;
@property(nonatomic, retain)InMemoryTick* monthlyWithdrawLimit;
@property(nonatomic, retain)InMemoryTick* openOrders;
@property(nonatomic, retain)NSNumber* operationCount;

@property(nonatomic, retain)NSArray* transaction;

@end