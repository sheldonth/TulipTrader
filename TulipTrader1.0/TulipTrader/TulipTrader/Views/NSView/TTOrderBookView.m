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
#import <WebKit/WebKit.h>

@interface TTOrderBookView()

@property(nonatomic, retain)TTCurrencyBox* currencyBox;
@property(nonatomic, retain)TTOrderBookListView* bidOrderBookListView;
@property(nonatomic, retain)TTOrderBookListView* askOrderBookListView;
@property(nonatomic, retain)TTStatusBox* statusBox;
@property(nonatomic, retain)TTVerticalOBGraphView* graphView;

@property(nonatomic, retain)WebView* webView;

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
            [self.askOrderBookListView setTitle:RUStringWithFormat(@"%lu ASKS", update.updateArrayPointer.count)];
            break;
            
        case TTOrderBookSideBid:
            [self.bidOrderBookListView updateForDepthUpdate:update];
            [self.graphView updateForBidSide:update];
            [self.bidOrderBookListView setTitle:RUStringWithFormat(@"%lu BIDS", update.updateArrayPointer.count)];
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
        
        [self setCurrencyBox:[[TTCurrencyBox alloc]initWithFrame:NSZeroRect]];
        
        [_currencyBox setOrderBookPtr:self.orderBook];
        
        [self addSubview:_currencyBox];
        
        [self setWebView:[[WebView alloc]initWithFrame:NSZeroRect frameName:@"SheldonsFrame" groupName:@"TulipTrader"]];
        
        [self addSubview:_webView];
        
        [_webView reload:self];
        
//        [self setGraphView:[[TTVerticalOBGraphView alloc]initWithFrame:NSZeroRect]];
        
//        [self addSubview:_graphView];
        
        //        [self setVerticalOBView:[[TTVerticalOBView alloc]initWithFrame:(NSRect){0, statusBarHeight, graphWidth, CGRectGetHeight(contentRect) - (currencyBoxHeight + statusBarHeight)}]];
        
        //        [self.verticalOBView setChartingProcedure:TTDepthViewChartingProcedureSampling];
        
        //        [self.contentView addSubview:_verticalOBView];
        
        [self setBidOrderBookListView:[[TTOrderBookListView alloc]initWithFrame:NSZeroRect]];
        
        [_bidOrderBookListView setTitle:@"BIDS"];
        
        [self.bidOrderBookListView setInvertsDataSource:YES];
        
        [self addSubview:self.bidOrderBookListView];
        
        [self setAskOrderBookListView:[[TTOrderBookListView alloc]initWithFrame:NSZeroRect]];
        
        [_askOrderBookListView setTitle:@"ASKS"];
        
        [self addSubview:_askOrderBookListView];
        
        [self setStatusBox:[[TTStatusBox alloc]initWithFrame:NSZeroRect]];
        
        [self addSubview:_statusBox];
        
        [self.orderBook setEventDelegate:self.statusBox];
        
        [self.orderBook start];
        
    }
    return self;
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    
    CGFloat currencyBoxHeight = floorf(CGRectGetHeight(frameRect) / 10);
    
    CGFloat statusBarHeight = floorf(CGRectGetHeight(frameRect) / 20);
    
    CGFloat graphWidth = floorf(CGRectGetWidth(frameRect) / 3) * 2;
    
    CGFloat graphHeight = floorf(CGRectGetHeight(frameRect) - (currencyBoxHeight + statusBarHeight));
    
    [_currencyBox setFrame:(NSRect){0, CGRectGetHeight(frameRect) - currencyBoxHeight, CGRectGetWidth(frameRect), currencyBoxHeight}];
    
//    [_graphView setFrame:(NSRect){0, statusBarHeight, graphWidth, graphHeight}];
    [_webView setFrame:(NSRect){0, statusBarHeight, graphWidth, graphHeight}];
    
    [_bidOrderBookListView setFrame:(NSRect){graphWidth, statusBarHeight - 5, graphWidth / 2, graphHeight / 2}];
    
    [_askOrderBookListView setFrame:(NSRect){graphWidth, CGRectGetMaxY(_bidOrderBookListView.frame) + 5, graphWidth / 2, graphHeight / 2}];
    
    [_statusBox setFrame:(NSRect){0, 0, CGRectGetWidth(frameRect), statusBarHeight - 10}];
}

@end
