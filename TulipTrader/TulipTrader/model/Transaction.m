//
//  Transaction.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/6/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "Transaction.h"
#import "Tick.h"
#import "RUClassOrNilUtil.h"

/*
 A transaction is an entry into or out of a wallet.
 It contains a TransactionTrade, which generally has it's most vital details.
 */

@implementation Transaction

+(Transaction*)transactionFromDictionary:(NSDictionary*)d
{
    Transaction* t = [Transaction new];
    [t setBalance:[InMemoryTick newInMemoryTickfromDictionary:[d objectForKey:@"Balance"]]];
    [t setDate:[NSDate dateWithTimeIntervalSince1970:[[d objectForKey:@"Date"]doubleValue]]];
    [t setIndex:[d objectForKey:@"Index"]];
    [t setLinkArray:[d objectForKey:@"Link"]];

    NSDictionary* transactionTradeDictionary = [d objectForKey:@"Trade"];
    TransactionTrade* transactionTrade = [TransactionTrade new];
    [transactionTrade setAmount:[InMemoryTick newInMemoryTickfromDictionary:[transactionTradeDictionary objectForKey:@"Amount"]]];
    [transactionTrade setProperties:[transactionTradeDictionary objectForKey:@"Properties"]];
    [transactionTrade setApp:kRUStringOrNil([transactionTradeDictionary objectForKey:@"app"])];
    [transactionTrade setOid:[transactionTradeDictionary objectForKey:@"oid"]];
    [transactionTrade setTid:[transactionTradeDictionary objectForKey:@"tid"]];

    [t setTrade:transactionTrade];
    [t setType:[d objectForKey:@"Type"]];
    [t setValue:[InMemoryTick newInMemoryTickfromDictionary:[d objectForKey:@"Value"]]];
    
    return t;
}

@end
