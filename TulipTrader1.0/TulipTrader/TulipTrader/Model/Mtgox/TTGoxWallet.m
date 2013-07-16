//
//  TTGoxWallet.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/31/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTGoxWallet.h"
#import "RUConstants.h"
#import "TTCurrency.h"
#import "TTTick.h"
#import "RUClassOrNilUtil.h"

@implementation TTGoxWallet

+(TTGoxWallet*)walletFromDictionary:(NSDictionary*)d
{
    TTGoxWallet* wallet = [TTGoxWallet new];
    [wallet setBalance:[TTTick newTickfromDictionary:kRUDictionaryOrNil([d objectForKey:@"Balance"])]];
    [wallet setDailyWithdrawalLimit:[TTTick newTickfromDictionary:kRUDictionaryOrNil([d objectForKey:@"Daily_Withdraw_Limit"])]];
    [wallet setMaxWithdraw:[TTTick newTickfromDictionary:kRUDictionaryOrNil([d objectForKey:@"Max_Withdraw"])]];
    [wallet setMonthlyWithdrawLimit:[TTTick newTickfromDictionary:kRUDictionaryOrNil([d objectForKey:@"Monthly_Withdraw_Limit"])]];
    [wallet setOpenOrders:[TTTick newTickfromDictionary:kRUDictionaryOrNil([d objectForKey:@"Open_Orders"])]];
    [wallet setOperationCount:[d objectForKey:@"Operations"]];
    return wallet;
}

-(NSString *)description
{
    return RUStringWithFormat(@"%@ %@ in %@ Operations",self.balance.display_short, stringFromCurrency(self.currency), self.operationCount.stringValue);
}

@end
