//
//  TTOrderBookWindow.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/24/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTOrderBookWindow.h"
#import "TTCurrencyBox.h"
#import "RUConstants.h"
#import "TTVerticalOBView.h"
#import "TTOrderBookListView.h"

@interface TTOrderBookWindow()

@property(nonatomic, retain)TTCurrencyBox* currencyBox;
@property(nonatomic, retain)TTVerticalOBView* verticalOBView;
@property(nonatomic, retain)TTOrderBookListView* bidOrderBookListView;
@property(nonatomic, retain)TTOrderBookListView* askOrderBookListView;

@end

@implementation TTOrderBookWindow

#pragma mark - TTOrderBookDelegate methods

-(void)orderBookHasNewDepth:(TTOrderBook *)orderBook
{
    if (!self.verticalOBView.needsCalibration)
    {
        [self.verticalOBView setAllBids:orderBook.bids];
        [self.verticalOBView setAllAsks:orderBook.asks];
        [self.verticalOBView processData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.verticalOBView display];
        });
    }
    [self.bidOrderBookListView setOrders:orderBook.bids];
}

-(void)orderBookHasNewLag:(TTOrderBook *)orderBook
{
    
}

-(void)orderBookHasNewTicker:(TTOrderBook *)orderBook
{
    TTTicker* newTicker = [orderBook lastTicker];
    [self.currencyBox setLastTicker:newTicker];
}

-(void)orderBookHasNewTrade:(TTOrderBook *)orderBook
{
    
}

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag currency:(TTCurrency)currency
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self)
    {
        _currency = currency;
        [self setOrderBook:[TTOrderBook newOrderBookForMTGOXwithCurrency:self.currency]];
        [self.orderBook setDelegate:self];
        
        CGFloat currencyBoxHeight = floorf(CGRectGetHeight(contentRect) / 10);
        
        CGFloat statusBarHeight = floorf(CGRectGetHeight(contentRect) / 20);
        
        CGFloat graphWidth = floorf(CGRectGetWidth(contentRect) / 3) * 2;
        
        [self setCurrencyBox:[[TTCurrencyBox alloc]initWithFrame:(NSRect){0, CGRectGetHeight(contentRect) - currencyBoxHeight, CGRectGetWidth(contentRect), currencyBoxHeight}]];
        [_currencyBox setOrderBookPtr:self.orderBook];
        [self.contentView addSubview:_currencyBox];
        
        [self setVerticalOBView:[[TTVerticalOBView alloc]initWithFrame:(NSRect){0, statusBarHeight, graphWidth, CGRectGetHeight(contentRect) - (currencyBoxHeight + statusBarHeight)}]];
        [self.verticalOBView setChartingProcedure:TTDepthViewChartingProcedureSampling];
        [self.contentView addSubview:_verticalOBView];
        
        [self setBidOrderBookListView:[[TTOrderBookListView alloc]initWithFrame:(NSRect){CGRectGetMaxX(self.verticalOBView.frame), statusBarHeight, graphWidth / 2, _verticalOBView.frame.size.height / 2}]];
        [_bidOrderBookListView setTitle:@"BIDS"];
        [self.contentView addSubview:self.bidOrderBookListView];
        
//        [self ]
        
        [self.orderBook start];
    }
    return self;
}

@end