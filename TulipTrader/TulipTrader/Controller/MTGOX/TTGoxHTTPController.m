//
//  TTGoxHTTPController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/7/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTGoxHTTPController.h"
#import "AFHTTPClient.h"
#import "RUConstants.h"
#import "Trade.h"

#define kTTMTGOXAPIV1 @"http://data.mtgox.com/api/1/"
#define kTTMTGOXAPIV2 @"https://data.mtgox.com/api/2/"

@interface TTGoxHTTPController()

@property(nonatomic, retain)AFHTTPClient* networkSecure;

@end

@implementation TTGoxHTTPController

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setNetworkSecure:[[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:kTTMTGOXAPIV2]]];
    }
    return self;
}

-(void)updateLatestTradesForCurrency:(TTGoxCurrency)currency
{
    [Trade computeFunctionNamed:@"max" onTradePropertyWithName:@"tradeId" completion:^(NSNumber *computedResult) {
            [self.networkSecure getPath:RUStringWithFormat(@"%@/money/trades/fetch", urlPathStringForCurrency(currency)) parameters:@{@"since": computedResult} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
    }];
}

@end
