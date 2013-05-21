//
//  TTGoxHTTPController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/7/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTGoxCurrency.h"

@interface TTGoxHTTPController : NSObject

-(void)updateLatestTradesForCurrency:(TTGoxCurrency)currency;

@end
