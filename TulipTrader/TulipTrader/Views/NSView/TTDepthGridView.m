//
//  TTDepthGridView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/11/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTDepthGridView.h"
#import "TTGoxHTTPController.h"
#import "RUConstants.h"
#import "TTGoxCurrencyController.h"
#import "TTDepthStackView.h"
#import "TTGoxCurrency.h"

@interface TTDepthGridView()

@property(nonatomic, retain)NSMutableArray* depthStackViewsArray;

@end

@implementation TTDepthGridView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setDepthStackViewsArray:[NSMutableArray array]];
        NSArray* __activeCurrencies = [TTGoxCurrencyController activeCurrencys];
        CGFloat stackWidth = floorf(CGRectGetWidth(frame) / __activeCurrencies.count);
        [__activeCurrencies enumerateObjectsUsingBlock:^(NSString* currencyStr, NSUInteger idx, BOOL *stop) {
            TTDepthStackView* depthStackView = [[TTDepthStackView alloc]initWithFrame:(NSRect){0 + (stackWidth * idx), 0, stackWidth, CGRectGetHeight(frame)}];
            if (currencyFromString(currencyStr) == TTGoxCurrencyUSD)
            {
                [depthStackView setCurrency:currencyFromString(currencyStr)];
                [self addSubview:depthStackView];
            }
        }];
    
    }
    
    return self;
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//    [[NSColor orangeColor] setFill];
//    NSRectFill(dirtyRect);
//}

@end
