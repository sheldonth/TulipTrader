//
//  TTGoxCurrencyController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/25/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTGoxCurrencyController.h"

@interface TTGoxCurrencyController ()



@end

static NSArray* currenciesStatic;
static NSDictionary* currencyUsagePairsStatic;

@implementation TTGoxCurrencyController

RU_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(TTGoxCurrencyController, sharedInstance);

+(void)initialize
{
    currenciesStatic = @[@"USD", @"AUD", @"CAD", @"CHF", @"CNY", @"DKK", @"EUR", @"GBP", @"HKD", @"JPY", @"NZD", @"PLN", @"RUB", @"SEK", @"SGD", @"THB"];
    currencyUsagePairsStatic = @{@"USD": @(1),
                           @"AUD": @(1),
                           @"CAD": @(1),
                           @"CHF": @(1),
                           @"CNY": @(1),
                           @"DKK": @(0),
                           @"EUR": @(1),
                           @"GBP": @(1),
                           @"HKD": @(0),
                           @"JPY": @(1),
                           @"NZD": @(0),
                           @"PLN": @(0),
                           @"RUB": @(0),
                           @"SEK": @(0),
                           @"SGD": @(0),
                           @"THB": @(0),};

}

+(NSArray*)activeCurrencys
{
    NSMutableArray* activeCurrencies = [NSMutableArray array];
    [[currencyUsagePairsStatic allKeys]enumerateObjectsUsingBlock:^(NSString* key, NSUInteger idx, BOOL *stop) {
        if ([[currencyUsagePairsStatic objectForKey:key] boolValue])
            [activeCurrencies addObject:key];
    }];
    return activeCurrencies;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setCurrencies:[currenciesStatic copy]];
        [self setCurrencyUsagePairs:[currencyUsagePairsStatic copy]];
    }
    return self;
}

@end
