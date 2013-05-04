//
//  TTArbitrageStackView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/1/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTArbitrageStackView.h"
#import "TTGoxCurrency.h"
#import "TTArbitrageBox.h"
#import "TTGoxCurrencyController.h"
#import "RUConstants.h"

@interface TTArbitrageStackView ()

#define kTTArbitrageBoxHeight 50

@property(nonatomic)NSMutableArray* arbitrageBoxes;

@end

@implementation TTArbitrageStackView

-(void)configureToCurrency:(TTGoxCurrency)currency
{
    [_arbitrageBoxes enumerateObjectsUsingBlock:^(TTArbitrageBox* obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    _arbitrageBoxes = nil;
    _arbitrageBoxes = [NSMutableArray array];
    NSMutableArray* __activeCurrenciesMutable = [NSMutableArray arrayWithArray:[TTGoxCurrencyController activeCurrencys]];
    [__activeCurrenciesMutable removeObject:stringFromCurrency(_baseCurrency)]; // Remove the primary party currency from the set every time
    [__activeCurrenciesMutable enumerateObjectsUsingBlock:^(NSString* currencyStr, NSUInteger idx, BOOL *stop) {
        TTArbitrageBox* arbBX = [TTArbitrageBox new];
        [arbBX setArbitrageStackCurrency:_baseCurrency];
        [arbBX setDeltaCurrency:currencyFromString(currencyStr)];
        [_arbitrageBoxes addObject:arbBX];
        [self addSubview:arbBX];
    }];
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
    [_arbitrageBoxes enumerateObjectsUsingBlock:^(TTArbitrageBox* obj, NSUInteger idx, BOOL *stop) {
        [obj setFrame:(NSRect){0, CGRectGetHeight(frameRect) - (((idx + 1) * kTTArbitrageBoxHeight) + (idx * 10)), CGRectGetWidth(frameRect), kTTArbitrageBoxHeight}];
    }];
}

@end
