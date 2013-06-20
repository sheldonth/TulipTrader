//
//  TTDepthGridView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/11/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTDepthGridView.h"
#import "TTGoxHTTPController.h"
#import "RUConstants.h"
#import "TTGoxCurrencyController.h"
#import "TTDepthStackView.h"
#import "TTGoxCurrency.h"
#import "TTDepthGridViewColumnView.h"

@interface TTDepthGridView()

@property(nonatomic, retain)NSMutableArray* columnsArray;

@end

@implementation TTDepthGridView

-(void)reloadAtIndex:(NSInteger)index
{
    [[self.columnsArray objectAtIndex:index]reload];
}

-(void)successionReload
{
    for (int i = 0; i < self.columnsArray.count; i++) {
        [self reloadAtIndex:i];
    };
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setColumnsArray:[NSMutableArray array]];
        NSArray* __activeCurrencies = [TTGoxCurrencyController activeCurrencys];
        CGFloat columnWidth = floorf(CGRectGetWidth(frame) / __activeCurrencies.count);
        [__activeCurrencies enumerateObjectsUsingBlock:^(NSString* currencyStr, NSUInteger idx, BOOL *stop) {
            TTDepthGridViewColumnView* column = [[TTDepthGridViewColumnView alloc]initWithFrame:(NSRect){columnWidth * idx, 0, columnWidth, CGRectGetHeight(frame)}];
            [column setCurrency:currencyFromString(currencyStr)];
            [self.columnsArray addObject:column];
            [self addSubview:column];
        }];
        [self successionReload];
    }
    return self;
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//    [[NSColor orangeColor] setFill];
//    NSRectFill(dirtyRect);
//}

@end
