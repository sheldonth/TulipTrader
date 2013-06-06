//
//  TTGoxCurrencyController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/25/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUSingleton.h"

@interface TTGoxCurrencyController : NSObject

RU_SYNTHESIZE_SINGLETON_DECLARATION_FOR_CLASS_WITH_ACCESSOR(TTGoxCurrencyController, sharedInstance);

@property(nonatomic, retain)NSArray* currencies;
@property(nonatomic, retain)NSDictionary* currencyUsagePairs;

+(NSArray*)activeCurrencys;

@end
