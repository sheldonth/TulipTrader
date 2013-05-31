//
//  TTGoxAccount.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/31/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTGoxAccount.h"
#import "TTGoxWallet.h"
#import "Tick.h"
#import "RUClassOrNilUtil.h"

@implementation TTGoxAccount

TTGoxAccount* accountFromDictionary(NSDictionary* accountDictionary)
{
    TTGoxAccount* acct = [TTGoxAccount new];
    [acct setUsername:[accountDictionary objectForKey:@"Login"]];
    [acct setID:[accountDictionary objectForKey:@"Id"]];
    [acct setLanguage:[accountDictionary objectForKey:@"Language"]];
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [acct setCreatedDate:[dateFormatter dateFromString:[accountDictionary objectForKey:@"Created"]]];
    [acct setLoginDate:[dateFormatter dateFromString:[accountDictionary objectForKey:@"Last_Login"]]];
    [acct setMonthlyVolume:[InMemoryTick newInMemoryTickfromDictionary:[accountDictionary objectForKey:@"Monthly_Volume"]]];
    [acct setPermissionsArray:[accountDictionary objectForKey:@"Rights"]];
    [acct setTradeFee:[accountDictionary objectForKey:@"Trade_Fee"]];
    
    NSMutableArray* wallets = [NSMutableArray array];
    
    NSDictionary* walletsDictionary = [accountDictionary objectForKey:@"Wallets"];
    [walletsDictionary.allKeys enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        TTGoxWallet* wallet = [TTGoxWallet new];
        [wallet setCurrency:currencyFromString(obj)];
        NSDictionary* walletDictionary = [walletsDictionary objectForKey:obj];
        [wallet setBalance:[InMemoryTick newInMemoryTickfromDictionary:kRUDictionaryOrNil([walletDictionary objectForKey:@"Balance"])]];
        [wallet setDailyWithdrawalLimit:[InMemoryTick newInMemoryTickfromDictionary:kRUDictionaryOrNil([walletDictionary objectForKey:@"Daily_Withdraw_Limit"])]];
        [wallet setMaxWithdraw:[InMemoryTick newInMemoryTickfromDictionary:kRUDictionaryOrNil([walletDictionary objectForKey:@"Max_Withdraw"])]];
        [wallet setMonthlyWithdrawLimit:[InMemoryTick newInMemoryTickfromDictionary:kRUDictionaryOrNil([walletDictionary objectForKey:@"Monthly_Withdraw_Limit"])]];
        [wallet setOpenOrders:[InMemoryTick newInMemoryTickfromDictionary:kRUDictionaryOrNil([walletDictionary objectForKey:@"Open_Orders"])]];
        [wallet setOperationCount:kRUNumberOrNil([walletDictionary objectForKey:@"Operations"])];
        [wallets addObject:wallet];
    }];
    [acct setCurrencyWallets:wallets];
    return acct;
}

@end
