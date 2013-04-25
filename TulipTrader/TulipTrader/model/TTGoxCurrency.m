//
//  TTGoxCurrency.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/19/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTGoxCurrency.h"
#import "RUConstants.h"

NSString* const goxUSDString = @"USD";
NSString* const goxBTCString = @"BTC";
NSString* const goxEURString = @"EUR";
NSString* const goxCADString = @"CAD";
NSString* const goxCHFString = @"CHF";
NSString* const goxCNYString = @"CNY";
NSString* const goxDKKString = @"DKK";
NSString* const goxGBPString = @"GBP";
NSString* const goxHKDString = @"HKD";
NSString* const goxJPYString = @"JPY";
NSString* const goxNZDString = @"NZD";
NSString* const goxPLNString = @"PLN";
NSString* const goxRUBString = @"RUB";
NSString* const goxSEKString = @"SEK";
NSString* const goxSGDString = @"SGD";
NSString* const goxTHBString = @"THB";
NSString* const goxAUDString = @"AUD";

#define ExceptionOnNoCurrencyFound 1

TTGoxCurrency currencyFromString(NSString* string)
{
    if ([string isEqualToString:goxBTCString])
        return TTGoxCurrencyBTC;
    else if ([string isEqualToString:goxUSDString])
        return TTGoxCurrencyUSD;
    else if ([string isEqualToString:goxEURString])
        return TTGoxCurrencyEUR;
    else if ([string isEqualToString:goxCADString])
        return TTGoxCurrencyCAD;
    else if ([string isEqualToString:goxCHFString])
        return TTGoxCurrencyCHF;
    else if ([string isEqualToString:goxCNYString])
        return TTGoxCurrencyCNY;
    else if ([string isEqualToString:goxDKKString])
        return TTGoxCurrencyDKK;
    else if ([string isEqualToString:goxGBPString])
        return TTGoxCurrencyGBP;
    else if ([string isEqualToString:goxHKDString])
        return TTGoxCurrencyHKD;
    else if ([string isEqualToString:goxJPYString])
        return TTGoxCurrencyJPY;
    else if ([string isEqualToString:goxNZDString])
        return TTGoxCurrencyNZD;
    else if ([string isEqualToString:goxPLNString])
        return TTGoxCurrencyPLN;
    else if ([string isEqualToString:goxRUBString])
        return TTGoxCurrencyRUB;
    else if ([string isEqualToString:goxSEKString])
        return TTGoxCurrencySEK;
    else if ([string isEqualToString:goxSGDString])
        return TTGoxCurrencySGD;
    else if ([string isEqualToString:goxTHBString])
        return TTGoxCurrencyTHB;
    else if ([string isEqualToString:goxAUDString])
        return TTGoxCurrencyAUD;
    else if (ExceptionOnNoCurrencyFound)
        [NSException raise:@"Currency Not Found" format:@"Currency %@ not found", string];

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