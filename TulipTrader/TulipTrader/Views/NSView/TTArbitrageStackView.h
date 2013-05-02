//
//  TTArbitrageStackView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/1/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTGoxCurrency.h"

@interface TTArbitrageStackView : NSView


// This is the base currency, for which the beginning 
@property(nonatomic)TTGoxCurrency baseCurrency;

@end
