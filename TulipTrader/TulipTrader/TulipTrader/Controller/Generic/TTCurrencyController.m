//
//  TTCurrencyController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/24/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTCurrencyController.h"
#import "RUConstants.h"
#import "TTCurrency.h"

@implementation TTCurrencyController

+(void)initialize
{
    if  (self == [TTCurrencyController class])
    {
        currenciesStatic = @[@"USD", @"AUD", @"CAD", @"CHF", @"CNY", @"DKK", @"EUR", @"GBP", @"HKD", @"JPY", @"NZD", @"PLN", @"RUB", @"SEK", @"SGD", @"THB"];
    }
}

// @purpose Each childclass must provide it's own prefix
-(NSString *)currencyProviderPrefix
{
    RU_MUST_OVERRIDE
    return nil;
}

-(void)setCurrency:(TTCurrency)currency active:(BOOL)active
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(active) forKey:RUStringWithFormat(@"%@%@", [self currencyProviderPrefix], stringFromCurrency(currency))];
    [defaults synchronize];
}

-(NSArray*)activeCurrencys
{
    NSMutableArray* activeCurrencyArray = [NSMutableArray array];
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults synchronize];
    [currenciesStatic enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        NSNumber* num = [standardUserDefaults objectForKey:RUStringWithFormat(@"%@%@", [self currencyProviderPrefix], obj)];
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
        [self setAvailableCurrencies:[currenciesStatic copy]];
    }
    return self;
}


@end
