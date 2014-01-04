//
//  TTAccountBalancesBox.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/25/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class JNWLabel;

@interface TTAccountBalancesBox : NSBox

@property(nonatomic, retain)NSButton* accountValuesReloadButton;

@property(nonatomic, retain)JNWLabel* accountValueLabel;

@property(nonatomic, retain)JNWLabel* primaryCurrencyLabel;

@property(nonatomic, retain)JNWLabel* bitcoinCurrencyLabel;

@property(nonatomic, retain)NSPopUpButton* walletSelectionPopUpButton;

@property(nonatomic, retain)NSButton* fastBuyButton;

@property(nonatomic, retain)NSButton* fastSellButton;

@end
