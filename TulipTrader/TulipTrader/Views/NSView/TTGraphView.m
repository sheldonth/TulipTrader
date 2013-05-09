//
//  TTGraphView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/9/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTGraphView.h"
#import <CorePlot/CorePlot.h>
#import "RUConstants.h"


@interface TTGraphView()

@property(nonatomic, retain)CPTXYGraph* graph;
@property(nonatomic, retain)CPTGraphHostingView* defaultLayerHostingView;
@property(nonatomic, retain)CPTMutableTextStyle* textStyle;

@end

static NSString* titleFontName;

@implementation TTGraphView

+(void)initialize
{
    if (self == [TTGraphView class])
    {
        titleFontName = @"Helvetica-Bold";
    }
}

-(void)setupGraphToCurrency:(TTGoxCurrency)currency
{
    if (!_graph)
        {NSException* e = [NSException exceptionWithName:NSInternalInconsistencyException reason:@"No graph object" userInfo:nil]; @throw e;}
    [self.graph applyTheme:[CPTTheme themeNamed:kCPTStocksTheme]];
    [self.graph setTitle:stringFromCurrency(currency)];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!_defaultLayerHostingView)
        {
            [self setDefaultLayerHostingView:[[CPTGraphHostingView alloc]initWithFrame:self.bounds]];
            [_defaultLayerHostingView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
            [self addSubview:_defaultLayerHostingView];
        }
        if (!_graph)
        {
            [self setGraph:[[CPTXYGraph alloc]initWithFrame:self.bounds]];
            [_defaultLayerHostingView setHostedGraph:_graph];
        }
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
}

#pragma mark - C methods

CPTMutableTextStyle* textStyleForCurrency(TTGoxCurrency currency)
{
    switch (currency) {
        default:
        {
            CPTMutableTextStyle* style = [CPTMutableTextStyle textStyle];
            [style setColor:[CPTColor grayColor]];
            break;
        }
    }
}

@end
