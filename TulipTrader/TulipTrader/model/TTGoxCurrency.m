//
//  TTGoxCurrency.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/19/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
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

#define ExceptionOnNoCurrencyFound 0

NSString* urlPathStringForCurrency(TTGoxCurrency currency)
{
    return RUStringWithFormat(@"BTC%@", stringFromCurrency(currency));
}

NSColor* colorForCurrency(TTGoxCurrency currency)
{
    return [NSColor redColor];
}

NSString* currencySymbolStringFromCurrency(TTGoxCurrency currency)
{
    switch (currency) {
        case TTGoxCurrencyBTC:
            return @"B⃦";
            break;
        case TTGoxCurrencyUSD: // US Dollar
            return @"$";
            break;
        case TTGoxCurrencyAUD: // Australian Dollar
            return @"A$";
            break;
        case TTGoxCurrencyCAD: // Canadian Dollar
            return @"C$";
            break;
        case TTGoxCurrencyCHF: // Swiss Franc
            return @"";
            break;
        case TTGoxCurrencyCNY: // Chinese Renminbi
            return @"¥";
            break;
        case TTGoxCurrencyDKK: // Danish Krone
            return @"";
            break;
        case TTGoxCurrencyEUR: // Euro
            return @"€";
            break;
        case TTGoxCurrencyGBP: // Great British Pound
            return @"£";
            break;
        case TTGoxCurrencyHKD: // Hong Kong Dollar
            return @"$";
            break;
        case TTGoxCurrencyJPY: // Japanese Yen
            return @"¥";
            break;
        case TTGoxCurrencyNZD: // New Zealand Dollar
            return @"$";
            break;
        case TTGoxCurrencyPLN: // Polish Zloty
            return @"zł";
            break;
        case TTGoxCurrencyRUB: // Russian Ruble
            return @"";
            break;
        case TTGoxCurrencySEK: // Swedish Krona
            return @"";
            break;
        case TTGoxCurrencySGD: // Singapore Dollar
            return @"$";
            break;
        case TTGoxCurrencyTHB: // Thai Bhat
            return @"฿";
            break;
        case TTGoxCurrencyNone:
        default:
            return @"ERR";
            break;
    }
}


NSString* bitcoinTickerChannelNameForCurrency(TTGoxCurrency currency)
{
    if (currency == TTGoxCurrencyBTC)
    {
        NSException *e = [NSException exceptionWithName:NSInvalidArgumentException reason:@"Can't ask for channel in bitcoin ticker channel itself, must be in terms of another currency." userInfo:@{@"currency": @(currency)}];
        @throw e;
    }
    return RUStringWithFormat(@"ticker.BTC%@", stringFromCurrency(currency));
}

NSString* stringFromCurrency(TTGoxCurrency currency)
{
    switch (currency) {
        case TTGoxCurrencyBTC:
            return goxBTCString;
            break;
        case TTGoxCurrencyUSD: // US Dollar
            return goxUSDString;
            break;
        case TTGoxCurrencyAUD: // Australian Dollar
            return goxAUDString;
            break;
        case TTGoxCurrencyCAD: // Canadian Dollar
            return goxCADString;
            break;
        case TTGoxCurrencyCHF: // Swiss Franc
            return goxCHFString;
            break;
        case TTGoxCurrencyCNY: // Chinese Renminbi
            return goxCNYString;
            break;
        case TTGoxCurrencyDKK: // Danish Krone
            return goxDKKString;
            break;
        case TTGoxCurrencyEUR: // Euro
            return goxEURString;
            break;
        case TTGoxCurrencyGBP: // Great British Pound
            return goxGBPString;
            break;
        case TTGoxCurrencyHKD: // Hong Kong Dollar
            return goxHKDString;
            break;
        case TTGoxCurrencyJPY: // Japanese Yen
            return goxJPYString;
            break;
        case TTGoxCurrencyNZD: // New Zealand Dollar
            return goxNZDString;
            break;
        case TTGoxCurrencyPLN: // Polish Zloty
            return goxPLNString;
            break;
        case TTGoxCurrencyRUB: // Russian Ruble
            return goxRUBString;
            break;
        case TTGoxCurrencySEK: // Swedish Krona
            return goxSEKString;
            break;
        case TTGoxCurrencySGD: // Singapore Dollar
            return goxSGDString;
            break;
        case TTGoxCurrencyTHB: // Thai Bhat
            return goxTHBString;
            break;
        case TTGoxCurrencyNone:
        default:
            return @"ERR";
            break;
    }
}

TTGoxCurrency currencyFromString(NSString* string)
{
    if ([string caseInsensitiveCompare:goxBTCString] == NSOrderedSame)
        return TTGoxCurrencyBTC;
    else if ([string caseInsensitiveCompare:goxUSDString] == NSOrderedSame)
        return TTGoxCurrencyUSD;
    else if ([string caseInsensitiveCompare:goxEURString] == NSOrderedSame)
        return TTGoxCurrencyEUR;
    else if ([string caseInsensitiveCompare:goxCADString] == NSOrderedSame)
        return TTGoxCurrencyCAD;
    else if ([string caseInsensitiveCompare:goxCHFString] == NSOrderedSame)
        return TTGoxCurrencyCHF;
    else if ([string caseInsensitiveCompare:goxCNYString] == NSOrderedSame)
        return TTGoxCurrencyCNY;
    else if ([string caseInsensitiveCompare:goxDKKString] == NSOrderedSame)
        return TTGoxCurrencyDKK;
    else if ([string caseInsensitiveCompare:goxGBPString] == NSOrderedSame)
        return TTGoxCurrencyGBP;
    else if ([string caseInsensitiveCompare:goxHKDString] == NSOrderedSame)
        return TTGoxCurrencyHKD;
    else if ([string caseInsensitiveCompare:goxJPYString] == NSOrderedSame)
        return TTGoxCurrencyJPY;
    else if ([string caseInsensitiveCompare:goxNZDString] == NSOrderedSame)
        return TTGoxCurrencyNZD;
    else if ([string caseInsensitiveCompare:goxPLNString] == NSOrderedSame)
        return TTGoxCurrencyPLN;
    else if ([string caseInsensitiveCompare:goxRUBString] == NSOrderedSame)
        return TTGoxCurrencyRUB;
    else if ([string caseInsensitiveCompare:goxSEKString] == NSOrderedSame)
        return TTGoxCurrencySEK;
    else if ([string caseInsensitiveCompare:goxSGDString] == NSOrderedSame)
        return TTGoxCurrencySGD;
    else if ([string caseInsensitiveCompare:goxTHBString] == NSOrderedSame)
        return TTGoxCurrencyTHB;
    else if ([string caseInsensitiveCompare:goxAUDString] == NSOrderedSame)
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

NSNumber* numberFromCurrency(TTGoxCurrency currency)
{
    return @(currency);
}