//
//  TTGoxHTTPController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/7/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUSingleton.h"
#import "TTHTTPController.h"
#import "TTTradeExecutionBox.h"

@class TTGoxWallet;

typedef enum{
    TTOrderTypeNone = 0,
    TTOrderTypeBid,
    TTOrderTypeAsk
}TTOrderType;

@interface TTGoxHTTPController : TTHTTPController

//-(void)updateLatestTradesForCurrency:(TTCurrency)currency;

//-(void)loadAccountDataWithCompletion:(void (^)(NSDictionary* accountInformationDictionary))callbackBlock andFailBlock:(void (^)(NSError* e))failBlock;

//-(void)getOrdersWithCompletion:(void (^)(NSArray* orders))completionBlock withFailBlock:(void (^)(NSError* e))failBlock;

//-(void)getAccountWebSocketKeyWithCompletion:(void (^)(NSString* accountKey))completion failBlock:(void (^)(NSError* e))failBlock;

//-(void)getTransactionsForWallet:(TTGoxWallet*)wallet withCompletion:(void (^)(TTGoxWallet* wallet))completionBlock withFailBlock:(void (^)(NSError* e))failBlock;

//-(void)getTransactionsForWallet:(TTGoxWallet*)wallet atPage:(NSInteger)historyPage recursivelyAppendingToMutableArray:(NSMutableArray*)array withCompletion:(void (^)(TTGoxWallet* wallet))completionBlock withFailBlock:(void (^)(NSError* e))failBlock;

-(void)loadAccountDataWithCompletion:(void (^)(NSDictionary* accountInformationDictionary))callbackBlock andFailBlock:(void (^)(NSError* e))failBlock;

-(void)getDepthForCurrency:(TTCurrency)currency withCompletion:(void (^)(NSArray* bids, NSArray* asks, NSDictionary* maxMinTicks))completionBlock withFailBlock:(void (^)(NSError* error))failBlock;

-(void)getFullDepthForCurrency:(TTCurrency)currency withCompletion:(void (^)(NSArray *bids, NSArray *asks, NSDictionary *maxMinTicks))completionBlock withFailBlock:(void (^)(NSError* error))failBlock;

-(void)getTransactionsForWallet:(TTGoxWallet*)wallet withCompletion:(void (^)(TTGoxWallet* wallet))completionBlock withFailBlock:(void (^)(NSError* e))failBlock;

-(void)placeOrder:(TTAccountWindowExecutionState)executionState amountInteger:(NSInteger)amountInteger placementType:(TTAccountWindowExecutionType)placementType priceInteger:(NSInteger)priceInteger withCompletion:(void (^)(BOOL success, NSDictionary* callbackData))completionBlock withFailBlock:(void (^)(NSError* error))failBlock;

-(void)getAccountWebSocketKeyWithCompletion:(void (^)(NSString* accountKey))completion failBlock:(void (^)(NSError* e))failBlock;

-(void)getQuoteForExecutionState:(TTAccountWindowExecutionState)executionState amount:(NSInteger)amountInteger withCompletion:(void (^)(NSNumber* cost))completion failBlock:(void (^)())failBlock;

@end
