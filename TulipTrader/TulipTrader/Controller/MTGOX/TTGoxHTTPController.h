//
//  TTGoxHTTPController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/7/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTGoxCurrency.h"
#import "RUSingleton.h"
#import "TTGoxWallet.h"
#import "TTGoxSocketController.h"

@interface TTGoxHTTPController : NSObject

-(void)updateLatestTradesForCurrency:(TTGoxCurrency)currency;

-(void)loadAccountDataWithCompletion:(void (^)(NSDictionary* accountInformationDictionary))callbackBlock andFailBlock:(void (^)(NSError* e))failBlock;

-(void)getOrdersWithCompletion:(void (^)(NSArray* orders))completionBlock withFailBlock:(void (^)(NSError* e))failBlock;

-(void)getAccountWebSocketKeyWithCompletion:(void (^)(NSString* accountKey))completion failBlock:(void (^)(NSError* e))failBlock;

-(void)getTransactionsForWallet:(TTGoxWallet*)wallet withCompletion:(void (^)(TTGoxWallet* wallet))completionBlock withFailBlock:(void (^)(NSError* e))failBlock;

-(void)getTransactionsForWallet:(TTGoxWallet*)wallet atPage:(NSInteger)historyPage recursivelyAppendingToMutableArray:(NSMutableArray*)array withCompletion:(void (^)(TTGoxWallet* wallet))completionBlock withFailBlock:(void (^)(NSError* e))failBlock;

-(void)getDepthForCurrency:(TTGoxCurrency)currency withCompletion:(void (^)(NSArray* bids, NSArray* asks, NSDictionary* maxMinTicks))completionBlock withFailBlock:(void (^)(NSError* e))failBlock;

RU_SYNTHESIZE_SINGLETON_DECLARATION_FOR_CLASS_WITH_ACCESSOR(TTGoxHTTPController, sharedInstance);

@end
