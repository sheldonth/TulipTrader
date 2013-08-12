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

typedef enum{
    TTGoxTransactionTypeNone = 0,
    TTGoxTransactionTypeBitcoinPurchase,
    TTGoxTransactionTypeBitcoinSale,
    TTGoxTransactionTypeFee,
    TTGoxTransactionTypeDeposit,
    TTGoxTransactionTypeWithdrawal
}TTGoxTransactionType;



@interface TTGoxTransaction : NSObject

@property(nonatomic, retain)TTTick* balance;

@property(nonatomic, retain)NSString* linkType;
@property(nonatomic, retain)NSNumber* linkIDNumber;
@property(nonatomic, retain)NSString* linkUniqueKey;

@property(nonatomic, retain)NSString* typeString;
@property(nonatomic, retain)TTGoxTransactionTrade* trade;

@property(nonatomic, retain)TTTick* feePaidValue;
@property(nonatomic, retain)TTTick* transactionValue;

@property(nonatomic)TTGoxTransactionType transactionType;

@property(nonatomic, retain)NSString* feeInfoString;
@property(nonatomic, retain)NSString* transactionInfoString;

@property(nonatomic, retain)NSDate* feeDate;
@property(nonatomic, retain)NSDate* transactionDate;
@property(nonatomic, retain)NSString* feeIndex;
@property(nonatomic, retain)NSString* transactionIndex;

-(NSNumber*)costBasis;
-(NSNumber*)feeEffectivePercentageNumber;

-(NSNumber*)effectiveAcquisitionAmount;

@end
