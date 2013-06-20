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
                           @"AUD": @(0),
                           @"CAD": @(0),
                           @"CHF": @(0),
                           @"CNY": @(0),
                           @"DKK": @(0),
                           @"EUR": @(0),
                           @"GBP": @(0),
                           @"HKD": @(0),
                           @"JPY": @(0),
                           @"NZD": @(0),
                           @"PLN": @(0),
                           @"RUB": @(0),
                           @"SEK": @(0),
                           @"SGD": @(0),
                           @"THB": @(0),};

}

+(void)setCurrency:(TTGoxCurrency)currency active:(BOOL)active
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(active) forKey:stringFromCurrency(currency)];
    [defaults synchronize];
}

+(NSArray*)activeCurrencys
{
    NSMutableArray* activeCurrencyArray = [NSMutableArray array];
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults synchronize];
    [currenciesStatic enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        NSNumber* num = [standardUserDefaults objectForKey:obj];
        if (num.boolValue)
            [activeCurrencyArray addObject:[currenciesStatic objectAtIndex:idx]];
    }];
    return activeCurrencyArray;
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
