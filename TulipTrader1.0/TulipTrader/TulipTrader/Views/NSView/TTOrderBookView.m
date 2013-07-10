//
//  TTOrderBookView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/24/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTOrderBookView.h"
#import "TTCurrencyBox.h"
#import "RUConstants.h"
#import "TTVerticalOBView.h"
#import "TTOrderBookListView.h"
#import "TTStatusBox.h"
#import "TTVerticalOBGraphView.h"

@interface TTOrderBookView()

@property(nonatomic, retain)TTCurrencyBox* currencyBox;
@property(nonatomic, retain)TTOrderBookListView* bidOrderBookListView;
@property(nonatomic, retain)TTOrderBookListView* askOrderBookListView;
@property(nonatomic, retain)TTStatusBox* statusBox;
@property(nonatomic, retain)TTVerticalOBGraphView* graphView;

//@property(nonatomic, retain)TTVerticalOBView* verticalOBView;

@end

@implementation TTOrderBookView

#pragma mark - TTOrderBookDelegate methods

-(void)orderBook:(TTOrderBook *)orderBook hasNewDepthUpdate:(TTDepthUpdate *)update orderBookSide:(TTOrderBookSide)side
{
    switch (side) {
        case TTOrderBookSideAsk:
            [self.askOrderBookListView updateForDepthUpdate:update];
            [self.graphView updateForAskSide:update];
            break;
            
        case TTOrderBookSideBid:
            [self.bidOrderBookListView updateForDepthUpdate:update];
            [self.graphView updateForBidSide:update];
            break;
            
        case TTOrderBookSideNone:
            RUDLog(@"TTOrderBookSideNone");
            break;
            
        default:
            break;
    }
    
//    if (!self.verticalOBView.needsCalibration)
//    {
//        [self.verticalOBView setAllBids:orderBook.bids];
//        [self.verticalOBView setAllAsks:orderBook.asks];
//        [self.verticalOBView processData];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.verticalOBView display];//calling display is poor
//        });
//    }
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

-(id)initWithFrame:(NSRect)frameRect currency:(TTCurrency)currency
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
//        [self setTitle:@"Order Book"];
        
        _currency = currency;
        
        [self setOrderBook:[TTOrderBook newOrderBookForMTGOXwithCurrency:self.currency]];
        
        [self.orderBook setDelegate:self];
        
        CGFloat currencyBoxHeight = floorf(CGRectGetHeight(frameRect) / 10);
        
        CGFloat statusBarHeight = floorf(CGRectGetHeight(frameRect) / 20);
        
        CGFloat graphWidth = floorf(CGRectGetWidth(frameRect) / 3) * 2;
        
        CGFloat graphHeight = floorf(CGRectGetHeight(frameRect) - (currencyBoxHeight + statusBarHeight));
        
        [self setCurrencyBox:[[TTCurrencyBox alloc]initWithFrame:(NSRect){0, CGRectGetHeight(frameRect) - currencyBoxHeight, CGRectGetWidth(frameRect), currencyBoxHeight}]];
        
        [_currencyBox setOrderBookPtr:self.orderBook];
        
        [self addSubview:_currencyBox];
        
        [self setGraphView:[[TTVerticalOBGraphView alloc]initWithFrame:(NSRect){0, statusBarHeight, graphWidth, graphHeight}]];
        
        [self addSubview:_graphView];
        
        //        [self setVerticalOBView:[[TTVerticalOBView alloc]initWithFrame:(NSRect){0, statusBarHeight, graphWidth, CGRectGetHeight(contentRect) - (currencyBoxHeight + statusBarHeight)}]];
        
        //        [self.verticalOBView setChartingProcedure:TTDepthViewChartingProcedureSampling];
        
        //        [self.contentView addSubview:_verticalOBView];
        
        [self setBidOrderBookListView:[[TTOrderBookListView alloc]initWithFrame:(NSRect){graphWidth, statusBarHeight - 5, graphWidth / 2, graphHeight / 2}]];
        
        [_bidOrderBookListView setTitle:@"BIDS"];
        
        [self.bidOrderBookListView setInvertsDataSource:YES];
        
        [self addSubview:self.bidOrderBookListView];
        
        [self setAskOrderBookListView:[[TTOrderBookListView alloc]initWithFrame:(NSRect){graphWidth, CGRectGetMaxY(_bidOrderBookListView.frame) + 5, graphWidth / 2, graphHeight / 2}]];
        
        [_askOrderBookListView setTitle:@"ASKS"];
        
        [self addSubview:_askOrderBookListView];
        
        [self setStatusBox:[[TTStatusBox alloc]initWithFrame:(NSRect){0, 0, CGRectGetWidth(frameRect), statusBarHeight - 10}]];
        
        [self addSubview:_statusBox];
        
        [self.orderBook setEventDelegate:self.statusBox];
        
        [self.orderBook start];
        
    }
    return self;
}

@end
