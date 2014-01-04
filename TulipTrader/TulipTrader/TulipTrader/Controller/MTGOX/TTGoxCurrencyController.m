//
//  TTGoxCurrencyController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/24/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTGoxCurrencyController.h"

@implementation TTGoxCurrencyController

+(void)initialize
{
    if  (self == [TTGoxCurrencyController class])
    {
        currenciesStatic = @[@"USD", @"AUD", @"CAD", @"CHF", @"CNY", @"DKK", @"EUR", @"GBP", @"HKD", @"JPY", @"NZD", @"PLN", @"RUB", @"SEK", @"SGD", @"THB"];
    }
}

-(NSString *)currencyProviderPrefix
{
    return @"MTGOX";
}

@end
