//
//  TTGoxHTTPController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/7/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTGoxCurrency.h"
#import "RUSingleton.h"

@interface TTGoxHTTPController : NSObject

-(void)updateLatestTradesForCurrency:(TTGoxCurrency)currency;

-(void)loadAccountData;

RU_SYNTHESIZE_SINGLETON_DECLARATION_FOR_CLASS_WITH_ACCESSOR(TTGoxHTTPController, sharedInstance);

@end
