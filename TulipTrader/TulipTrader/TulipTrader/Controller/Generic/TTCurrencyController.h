//
//  TTCurrencyController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/24/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTCurrency.h"

// Child classes must implement +(void)initalize and set the currenciesStatic array to all the currency strings of currencies offered

static NSArray* currenciesStatic;

@interface TTCurrencyController : NSObject

-(NSString*)currencyProviderPrefix;
-(NSArray*)activeCurrencys;
-(void)setCurrency:(TTCurrency)currency active:(BOOL)active;

@property(nonatomic, retain)NSArray* availableCurrencies;

@end
