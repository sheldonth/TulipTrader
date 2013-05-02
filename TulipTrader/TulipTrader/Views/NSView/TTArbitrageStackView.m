//
//  TTArbitrageStackView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/1/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTArbitrageStackView.h"
#import "TTGoxCurrency.h"

@interface TTArbitrageStackView ()

@property(nonatomic)NSMutableArray* arbitrageBoxes;

@end

@implementation TTArbitrageStackView

-(void)configureToCurrency:(TTGoxCurrency)currency
{
    
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setArbitrageBoxes:[NSMutableArray array]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
}

-(void)setBaseCurrency:(TTGoxCurrency)baseCurrency
{
    [self willChangeValueForKey:@"baseCurrency"];
    _baseCurrency = baseCurrency;
    [self configureToCurrency:baseCurrency];
    [self didChangeValueForKey:@"baseCurrency"];
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    
}

@end
