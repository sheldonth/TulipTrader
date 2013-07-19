//
//  Transaction.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/6/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTGoxTransaction.h"
#import "TTTick.h"
#import "RUClassOrNilUtil.h"
#import "TTGoxTransactionTrade.h"

/*
 A transaction is an entry into or out of a wallet.
 It contains a TransactionTrade, which generally has it's most vital details.
 */

@implementation TTGoxTransaction

+(TTGoxTransaction*)transactionFromDictionary:(NSDictionary*)d
{
    TTGoxTransaction* t = [TTGoxTransaction new];
    [t setBalance:[TTTick newTickfromDictionary:[d objectForKey:@"Balance"]]];
    [t setDate:[NSDate dateWithTimeIntervalSince1970:[[d objectForKey:@"Date"]doubleValue]]];
    [t setIndex:[d objectForKey:@"Index"]];
    [t setLinkArray:[d objectForKey:@"Link"]];
    [t setInfoString:[d objectForKey:@"Info"]];
    
    NSDictionary* transactionTradeDictionary = [d objectForKey:@"Trade"];
    TTGoxTransactionTrade* transactionTrade = [TTGoxTransactionTrade newTransactionTradeFromDictionary:transactionTradeDictionary];    
    [t setTrade:transactionTrade];
    [t setType:[d objectForKey:@"Type"]];
    [t setValue:[TTTick newTickfromDictionary:[d objectForKey:@"Value"]]];
    return t;
}

@end
