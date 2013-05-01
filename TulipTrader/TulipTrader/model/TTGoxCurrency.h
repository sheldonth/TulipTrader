//
//  TTGoxCurrency.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/19/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    TTGoxCurrencyNone = 0,
    TTGoxCurrencyBTC, // Bitcoin
    TTGoxCurrencyUSD, // US Dollar
    TTGoxCurrencyAUD, // Australian Dollar
    TTGoxCurrencyCAD, // Canadian Dollar
    TTGoxCurrencyCHF, // Swiss Franc
    TTGoxCurrencyCNY, // Chinese Renminbi
    TTGoxCurrencyDKK, // Danish Krone
    TTGoxCurrencyEUR, // Euro
    TTGoxCurrencyGBP, // Great British Pound
    TTGoxCurrencyHKD, // Hong Kong Dollar
    TTGoxCurrencyJPY, // Japanese Yen
    TTGoxCurrencyNZD, // New Zealand Dollar
    TTGoxCurrencyPLN, // Polish Zloty
    TTGoxCurrencyRUB, // Russian Ruble
    TTGoxCurrencySEK, // Swedish Krona
    TTGoxCurrencySGD, // Singapore Dollar
    TTGoxCurrencyTHB  // Thai Bhat
}TTGoxCurrency;

// Makes string consts available outside class's implementation
extern NSString* const goxUSDString;
extern NSString* const goxBTCString;

TTGoxCurrency currencyFromNumber(NSNumber* number);
TTGoxCurrency currencyFromString(NSString* string);
NSNumber* numberFromCurrencyString(NSString* string);
NSString* stringFromCurrency(TTGoxCurrency currency);
NSNumber* numberFromCurrency(TTGoxCurrency currency);
NSString* bitcoinTickerChannelNameForCurrency(TTGoxCurrency currency);
