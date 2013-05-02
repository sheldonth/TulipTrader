//
//  TTArbitrageBox.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/1/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTArbitrageBox.h"


@interface TTArbitrageBox ()

@end


@implementation TTArbitrageBox

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBitcoinBase:TTGoxCurrencyBTC]; // weird line of code
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
