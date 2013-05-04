//
//  TTArbitrageBox.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/1/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTGoxCurrency.h"

@interface TTArbitrageBox : NSBox

@property(nonatomic, readonly)TTGoxCurrency bitcoinBase;
@property(nonatomic, readwrite)TTGoxCurrency arbitrageStackCurrency;
@property(nonatomic, readwrite)TTGoxCurrency deltaCurrency;

-(void)arbitrate;

@end
