//
//  TTGoxWallet.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/31/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTGoxWallet.h"
#import "RUConstants.h"
#import "TTGoxCurrency.h"

@implementation TTGoxWallet

-(NSString *)description
{
    return RUStringWithFormat(@"%@ %@ in %@ Operations",self.balance.display_short, stringFromCurrency(self.currency), self.operationCount.stringValue);
}

@end
