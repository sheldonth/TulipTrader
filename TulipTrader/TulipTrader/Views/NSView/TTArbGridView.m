//
//  TTArbGridView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/11/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTArbGridView.h"
#import "TTGoxCurrencyController.h"
#import "TTArbitrageStackView.h"
#import "JNWLabel.h"

@interface TTArbGridView()

@property(nonatomic, retain)NSMutableArray* arbitrageStackViewsArray;
@property(nonatomic)CGFloat stackWidth;
//@property(nonatomic, retain)JNWLabel* 

@end

@implementation TTArbGridView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setArbitrageStackViewsArray:[NSMutableArray array]];
        NSArray* __activeCurrencies = [TTGoxCurrencyController activeCurrencys];
        _stackWidth = floorf(CGRectGetWidth(frame) / __activeCurrencies.count);
        [__activeCurrencies enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
            NSRect targetFrame = (NSRect){0 + (idx * _stackWidth),0,_stackWidth,CGRectGetHeight(frame)};
            TTArbitrageStackView* stackView = [[TTArbitrageStackView alloc]initWithFrame:targetFrame];
            [stackView setBaseCurrency:currencyFromString(obj)];
            [stackView setFrame:targetFrame];
            [self addSubview:stackView];
            [self.arbitrageStackViewsArray addObject:stackView];
        }];
    }
    return self;
}



@end
