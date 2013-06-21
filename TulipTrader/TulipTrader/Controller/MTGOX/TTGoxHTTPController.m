//
//  TTGoxHTTPController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/7/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTGoxHTTPController.h"
#import "AFHTTPClient.h"
#import "RUConstants.h"
#import "Trade.h"
#import "RUConstants.h"
#import "JSONKit.h"
#import "TTAPIControlBoxView.h"
#import "TTAppDelegate.h"
#import "Trade.h"
#import "TTGoxHTTPClient.h"
#import "Order.h"
#import "TTGoxWallet.h"
#import "AFHTTPRequestOperation.h"
#import "Transaction.h"
#import "TTDepthOrder.h"

#define kTTMTGOXAPIV1 @"http://data.mtgox.com/api/1/"
#define kTTMTGOXAPIV2 @"https://data.mtgox.com/api/2/"

static dispatch_queue_t dataProcessQueue;
static TTAppDelegate* appDelegatePtr;

@interface TTGoxHTTPController()

@property(nonatomic, retain)TTGoxHTTPClient* networkSecure;

@end

@implementation TTGoxHTTPController

RU_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(TTGoxHTTPController, sharedInstance);

+(void)initialize
{
    dataProcessQueue = dispatch_queue_create("mtgox.api.processQueue", NULL);
    appDelegatePtr = (TTAppDelegate*)[[NSApplication sharedApplication]delegate];
}

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setNetworkSecure:[[TTGoxHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:kTTMTGOXAPIV2]]];
    }
    return self;
}

-(void)getTransactionsForWallet:(TTGoxWallet*)wallet withCompletion:(void (^)(TTGoxWallet* wallet))completionBlock withFailBlock:(void (^)(NSError* e))failBlock
{
    [self getTransactionsForWallet:wallet atPage:0 recursivelyAppendingToMutableArray:nil withCompletion:completionBlock withFailBlock:failBlock];
}

-(void)getTransactionsForWallet:(TTGoxWallet*)wallet atPage:(NSInteger)historyPage recursivelyAppendingToMutableArray:(NSMutableArray*)array withCompletion:(void (^)(TTGoxWallet* wallet))completionBlock withFailBlock:(void (^)(NSError* e))failBlock
{
    NSDictionary* paramDic;
    if (historyPage)
        paramDic = @{@"currency": stringFromCurrency(wallet.currency), @"page": @(historyPage)};
    else
        paramDic = @{@"currency": stringFromCurrency(wallet.currency)};
    
    if (!array)
        array = [NSMutableArray array];
    
    [self.networkSecure postPath:RUStringWithFormat(@"money/wallet/history") parameters:paramDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* a = [[NSString alloc]initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
        NSDictionary* responseDictionary = [a objectFromJSONString];
        NSDictionary* dataResults = [responseDictionary objectForKey:@"data"];
        NSArray* transactions = [dataResults objectForKey:@"result"];
        [transactions enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
            Transaction* t = [Transaction transactionFromDictionary:obj];
            [array addObject:t];
        }];
        NSNumber* currentPage = [dataResults objectForKey:@"current_page"];
        NSNumber* maxPage = [dataResults objectForKey:@"max_page"];
        if (currentPage.intValue < maxPage.intValue)
            [self getTransactionsForWallet:wallet atPage:(currentPage.intValue + 1) recursivelyAppendingToMutableArray:array withCompletion:completionBlock withFailBlock:failBlock];
        else
        {
            [wallet setTransactions:array];
            completionBlock(wallet);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        RUDLog(@"WALLET HISTORY FAILED %@", stringFromCurrency(wallet.currency));
    }];
}

-(void)getOrdersWithCompletion:(void (^)(NSArray* orders))completionBlock withFailBlock:(void (^)(NSError* e))failBlock
{
    [self.networkSecure postPath:@"BTCUSD/money/orders" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* a = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary* d = [a objectFromJSONString];
        NSArray* dataArray = [d objectForKey:@"data"];
        NSMutableArray* orderArray = [NSMutableArray array];
        [dataArray enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
            Order* order = [Order newOrderFromDictionary:obj];
            [orderArray addObject:order];
        }];
        completionBlock(orderArray);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failBlock(error);
    }];
}

-(void)getDepthForCurrency:(TTGoxCurrency)currency withCompletion:(void (^)(NSArray* bids, NSArray* asks, NSDictionary* maxMinTicks))completionBlock withFailBlock:(void (^)(NSError* e))failBlock
{
    [self.networkSecure postPath:RUStringWithFormat(@"%@/money/depth/fetch", urlPathStringForCurrency(currency)) parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* a = [[NSString alloc]initWithData:(NSData*)responseObject encoding:NSUTF8StringEncoding];
        NSDictionary* responseDictionary = [a objectFromJSONString];
        NSDictionary* data = [responseDictionary objectForKey:@"data"];

        NSMutableArray* bidObjects = [NSMutableArray array];
        NSMutableArray* askObjects = [NSMutableArray array];

        NSArray* bids = [data objectForKey:@"bids"];
        NSArray* asks = [data objectForKey:@"asks"];

        [bids enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
            [bidObjects addObject:[TTDepthOrder newDepthOrderFromGOXHTTPDictionary:obj]];
        }];
        
        [asks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [askObjects addObject:[TTDepthOrder newDepthOrderFromGOXHTTPDictionary:obj]];
        }];
        
        completionBlock(bidObjects, askObjects, @{@"filter_max_price": [data objectForKey:@"filter_max_price"], @"filter_min_price": [data objectForKey:@"filter_min_price"]});
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failBlock(error);
    }];
}

-(void)getAccountWebSocketKeyWithCompletion:(void (^)(NSString* accountKey))completion failBlock:(void (^)(NSError* e))failBlock
{
    [self.networkSecure postPath:@"BTCUSD/money/idkey" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* s = [[NSString alloc]initWithData:(NSData*)responseObject encoding:NSUTF8StringEncoding];
        NSDictionary* d = [s objectFromJSONString];
        NSString* accountKey = [d objectForKey:@"data"];
        completion(accountKey);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failBlock(error);
    }];
}

-(void)loadAccountDataWithCompletion:(void (^)(NSDictionary* accountInformationDictionary))callbackBlock andFailBlock:(void (^)(NSError* e))failBlock
{
    NSString* path = @"BTCUSD/money/info";
    [self.networkSecure postPath:path parameters:@{@"test": @"object"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* str = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary* d = [str objectFromJSONString];
        if (![[d objectForKey:@"result"]isEqualToString:@"success"])
            failBlock(nil);
        else
            callbackBlock([d objectForKey:@"data"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failBlock(error);
    }];
}

-(void)updateLatestTradesForCurrency:(TTGoxCurrency)currency
{
    __block NSInteger iterative = 0;
    [Trade computeFunctionNamed:@"max:" onTradePropertyWithName:@"tradeId" completion:^(NSNumber *computedResult) {
        [TTAPIControlBoxView publishCommand:RUStringWithFormat(@"Loadinging dataset %li for %@ on MTGOX", iterative, stringFromCurrency(currency))];
            [self.networkSecure getPath:RUStringWithFormat(@"%@/money/trades/fetch", urlPathStringForCurrency(currency)) parameters:@{@"since": computedResult} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString* result = [[NSString alloc]initWithData:(NSData*)responseObject encoding:NSUTF8StringEncoding];
                NSDictionary* aDict = [result objectFromJSONString];
                if ([[aDict objectForKey:@"result"]isEqualToString:@"success"])
                {
                    NSArray* tradeArray = [aDict objectForKey:@"data"];
                    dispatch_async(dataProcessQueue, ^{
                        NSManagedObjectContext* c = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                        [c setPersistentStoreCoordinator:appDelegatePtr.persistentStoreCoordinator];
                        __block Trade* lastTrade = nil;
                        [tradeArray enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
                            lastTrade = [Trade newNetworkTradeInContext:c fromDictionary:obj];
                        }];
                        [c performBlock:^{
                            NSError* e = nil;
                            [c save:&e];
                            if (e)
                                RUDLog(@"Error Saving Trade Data");
                            else
                            {
                                [TTAPIControlBoxView publishCommand:RUStringWithFormat(@"Updated to tid %@ at %@", lastTrade.tradeId, lastTrade.date)];
                                if (tradeArray.count > 1)
                                {
                                    [self updateLatestTradesForCurrency:currency];
                                    iterative++;
                                }
                                else
                                    [TTAPIControlBoxView publishCommand:RUStringWithFormat(@"Done Loading %@", stringFromCurrency(currency))];
                            }
                        }];
                    });
                }
                else
                    [TTAPIControlBoxView publishCommand:RUStringWithFormat(@"Server Returned Non-Success State: %@", [aDict objectForKey:@"result"])];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [TTAPIControlBoxView publishCommand:RUStringWithFormat(@"Server Request Did Fail With Error %@", error.localizedDescription)];
            }];
    }];
}

@end
