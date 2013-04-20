//
//  TTGoxCurrency.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/19/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTGoxCurrency.h"

NSString* const goxUSDString = @"USD";
NSString* const goxBTCString = @"BTC";

TTGoxCurrency currencyFromString(NSString* string)
{
    if ([string isEqualToString:goxBTCString])
        return TTGoxCurrencyBTC;
    else if ([string isEqualToString:goxUSDString])
        return TTGoxCurrencyUSD;
    else
        return TTGoxCurrencyNone;
}

TTGoxCurrency currencyFromNumber(NSNumber* number)
{
    return number.intValue;
}

NSNumber* numberFromCurrencyString(NSString* string)
{
    TTGoxCurrency currency = currencyFromString(string);
    return @(currency);
}