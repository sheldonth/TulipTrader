//
//  TTCurrencyBox.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/25/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTGoxCurrency.h"
#import "Trade.h"

@interface TTCurrencyBox : NSBox

@property(nonatomic)TTGoxCurrency currency;

@end
