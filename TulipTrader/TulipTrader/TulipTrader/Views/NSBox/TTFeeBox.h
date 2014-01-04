//
//  TTFeeBox.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/22/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTCurrency.h"
#import "TTGoxWallet.h"
#import "TTTicker.h"

@interface TTFeeBox : NSBox

-(void)setAccountInformationToDictionary:(NSDictionary*)dic;

-(void)setWalletForFeeDetermination:(TTGoxWallet*)wallet;

-(void)setLastTicker:(TTTicker*)lastTicker;

@end

