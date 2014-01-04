//
//  TTGoxTransactionTrade.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/18/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTGoxTransactionTrade.h"
#import "TTTick.h"
#import "RUClassOrNilUtil.h"
#import "RUConstants.h"

@implementation TTGoxTransactionTrade

-(NSString *)description
{
    return RUStringWithFormat(@"%@ %@ %@ %@ %@", self.amount.display, self.properties, self.app, self.oid, self.tid);
}

+(TTGoxTransactionTrade*)newTransactionTradeFromDictionary:(NSDictionary*)d
{
    TTGoxTransactionTrade* transactionTrade = [TTGoxTransactionTrade new];
    [transactionTrade setAmount:[TTTick newTickfromDictionary:[d objectForKey:@"Amount"]]];
    [transactionTrade setProperties:[d objectForKey:@"Properties"]];
    [transactionTrade setApp:kRUStringOrNil([d objectForKey:@"app"])];
    [transactionTrade setOid:[d objectForKey:@"oid"]];
    [transactionTrade setTid:[d objectForKey:@"tid"]];
    return transactionTrade;
}

@end
