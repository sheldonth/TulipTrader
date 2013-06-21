//
//  TTCurrency.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/21/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    TTCurrencyNone = 0,
    TTCurrencyBTC, // Bitcoin
    TTCurrencyUSD, // US Dollar
    TTCurrencyAUD, // Australian Dollar
    TTCurrencyCAD, // Canadian Dollar
    TTCurrencyCHF, // Swiss Franc
    TTCurrencyCNY, // Chinese Renminbi
    TTCurrencyDKK, // Danish Krone
    TTCurrencyEUR, // Euro
    TTCurrencyGBP, // Great British Pound
    TTCurrencyHKD, // Hong Kong Dollar
    TTCurrencyJPY, // Japanese Yen
    TTCurrencyNZD, // New Zealand Dollar
    TTCurrencyPLN, // Polish Zloty
    TTCurrencyRUB, // Russian Ruble
    TTCurrencySEK, // Swedish Krona
    TTCurrencySGD, // Singapore Dollar
    TTCurrencyTHB  // Thai Bhat
}TTCurrency;

NSString* currencySymbolStringFromCurrency(TTCurrency currency);
NSString* stringFromCurrency(TTCurrency currency);
TTCurrency currencyFromString(NSString* string);
TTCurrency currencyFromNumber(NSNumber* number);
NSNumber* numberFromCurrencyString(NSString* string);
NSNumber* numberFromCurrency(TTCurrency currency);

