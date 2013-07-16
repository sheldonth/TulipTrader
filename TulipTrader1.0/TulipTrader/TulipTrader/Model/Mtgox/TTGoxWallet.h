//
//  TTGoxWallet.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/31/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTCurrency.h"
#import "TTTick.h"

@interface TTGoxWallet : NSObject

@property(nonatomic)TTCurrency currency;
@property(nonatomic, retain)TTTick* balance;
@property(nonatomic, retain)TTTick* dailyWithdrawalLimit;
@property(nonatomic, retain)TTTick* maxWithdraw;
@property(nonatomic, retain)TTTick* monthlyWithdrawLimit;
@property(nonatomic, retain)TTTick* openOrders;
@property(nonatomic, retain)NSNumber* operationCount;

@property(nonatomic, retain)NSArray* transactions;

+(TTGoxWallet*)walletFromDictionary:(NSDictionary*)d;

@end