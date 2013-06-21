//
//  TTCurrency.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/21/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTCurrency.h"

NSString* const USDString = @"USD";
NSString* const BTCString = @"BTC";
NSString* const EURString = @"EUR";
NSString* const CADString = @"CAD";
NSString* const CHFString = @"CHF";
NSString* const CNYString = @"CNY";
NSString* const DKKString = @"DKK";
NSString* const GBPString = @"GBP";
NSString* const HKDString = @"HKD";
NSString* const JPYString = @"JPY";
NSString* const NZDString = @"NZD";
NSString* const PLNString = @"PLN";
NSString* const RUBString = @"RUB";
NSString* const SEKString = @"SEK";
NSString* const SGDString = @"SGD";
NSString* const THBString = @"THB";
NSString* const AUDString = @"AUD";

#define ExceptionOnNoCurrencyFound 0

NSString* currencySymbolStringFromCurrency(TTCurrency currency)
{
    switch (currency) {
        case TTCurrencyBTC:
            return @"B⃦";
            break;
        case TTCurrencyUSD: // US Dollar
            return @"$";
            break;
        case TTCurrencyAUD: // Australian Dollar
            return @"A$";
            break;
        case TTCurrencyCAD: // Canadian Dollar
            return @"C$";
            break;
        case TTCurrencyCHF: // Swiss Franc
            return @"";
            break;
        case TTCurrencyCNY: // Chinese Renminbi
            return @"¥";
            break;
        case TTCurrencyDKK: // Danish Krone
            return @"";
            break;
        case TTCurrencyEUR: // Euro
            return @"€";
            break;
        case TTCurrencyGBP: // Great British Pound
            return @"£";
            break;
        case TTCurrencyHKD: // Hong Kong Dollar
            return @"$";
            break;
        case TTCurrencyJPY: // Japanese Yen
            return @"¥";
            break;
        case TTCurrencyNZD: // New Zealand Dollar
            return @"$";
            break;
        case TTCurrencyPLN: // Polish Zloty
            return @"zł";
            break;
        case TTCurrencyRUB: // Russian Ruble
            return @"";
            break;
        case TTCurrencySEK: // Swedish Krona
            return @"";
            break;
        case TTCurrencySGD: // Singapore Dollar
            return @"$";
            break;
        case TTCurrencyTHB: // Thai Bhat
            return @"฿";
            break;
        case TTCurrencyNone:
        default:
            return @"ERR";
            break;
    }
}

NSString* stringFromCurrency(TTCurrency currency)
{
    switch (currency) {
        case TTCurrencyBTC:
            return BTCString;
            break;
        case TTCurrencyUSD: // US Dollar
            return USDString;
            break;
        case TTCurrencyAUD: // Australian Dollar
            return AUDString;
            break;
        case TTCurrencyCAD: // Canadian Dollar
            return CADString;
            break;
        case TTCurrencyCHF: // Swiss Franc
            return CHFString;
            break;
        case TTCurrencyCNY: // Chinese Renminbi
            return CNYString;
            break;
        case TTCurrencyDKK: // Danish Krone
            return DKKString;
            break;
        case TTCurrencyEUR: // Euro
            return EURString;
            break;
        case TTCurrencyGBP: // Great British Pound
            return GBPString;
            break;
        case TTCurrencyHKD: // Hong Kong Dollar
            return HKDString;
            break;
        case TTCurrencyJPY: // Japanese Yen
            return JPYString;
            break;
        case TTCurrencyNZD: // New Zealand Dollar
            return NZDString;
            break;
        case TTCurrencyPLN: // Polish Zloty
            return PLNString;
            break;
        case TTCurrencyRUB: // Russian Ruble
            return RUBString;
            break;
        case TTCurrencySEK: // Swedish Krona
            return SEKString;
            break;
        case TTCurrencySGD: // Singapore Dollar
            return SGDString;
            break;
        case TTCurrencyTHB: // Thai Bhat
            return THBString;
            break;
        case TTCurrencyNone:
        default:
            return @"ERR";
            break;
    }
}

TTCurrency currencyFromString(NSString* string)
{
    if ([string caseInsensitiveCompare:BTCString] == NSOrderedSame)
        return TTCurrencyBTC;
    else if ([string caseInsensitiveCompare:USDString] == NSOrderedSame)
        return TTCurrencyUSD;
    else if ([string caseInsensitiveCompare:EURString] == NSOrderedSame)
        return TTCurrencyEUR;
    else if ([string caseInsensitiveCompare:CADString] == NSOrderedSame)
        return TTCurrencyCAD;
    else if ([string caseInsensitiveCompare:CHFString] == NSOrderedSame)
        return TTCurrencyCHF;
    else if ([string caseInsensitiveCompare:CNYString] == NSOrderedSame)
        return TTCurrencyCNY;
    else if ([string caseInsensitiveCompare:DKKString] == NSOrderedSame)
        return TTCurrencyDKK;
    else if ([string caseInsensitiveCompare:GBPString] == NSOrderedSame)
        return TTCurrencyGBP;
    else if ([string caseInsensitiveCompare:HKDString] == NSOrderedSame)
        return TTCurrencyHKD;
    else if ([string caseInsensitiveCompare:JPYString] == NSOrderedSame)
        return TTCurrencyJPY;
    else if ([string caseInsensitiveCompare:NZDString] == NSOrderedSame)
        return TTCurrencyNZD;
    else if ([string caseInsensitiveCompare:PLNString] == NSOrderedSame)
        return TTCurrencyPLN;
    else if ([string caseInsensitiveCompare:RUBString] == NSOrderedSame)
        return TTCurrencyRUB;
    else if ([string caseInsensitiveCompare:SEKString] == NSOrderedSame)
        return TTCurrencySEK;
    else if ([string caseInsensitiveCompare:SGDString] == NSOrderedSame)
        return TTCurrencySGD;
    else if ([string caseInsensitiveCompare:THBString] == NSOrderedSame)
        return TTCurrencyTHB;
    else if ([string caseInsensitiveCompare:AUDString] == NSOrderedSame)
        return TTCurrencyAUD;
    else if (ExceptionOnNoCurrencyFound)
        [NSException raise:@"Currency Not Found" format:@"Currency %@ not found", string];
    
    return TTCurrencyNone;
}

TTCurrency currencyFromNumber(NSNumber* number)
{
    return number.intValue;
}

NSNumber* numberFromCurrencyString(NSString* string)
{
    TTCurrency currency = currencyFromString(string);
    return @(currency);
}

NSNumber* numberFromCurrency(TTCurrency currency)
{
    return @(currency);
}
