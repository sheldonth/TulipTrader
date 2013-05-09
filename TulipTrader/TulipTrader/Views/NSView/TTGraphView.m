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

#define kTTGraphStrongSidePadding 55.f
#define kTTGraphWeakSidePadding 15.f

@interface TTGraphView()

@property(nonatomic, retain)CPTXYGraph* graph;
@property(nonatomic, retain)CPTGraphHostingView* defaultLayerHostingView;
@property(nonatomic, retain)CPTMutableTextStyle* textStyle;

CPTMutableTextStyle* textStyleForCurrency(TTGoxCurrency currency);

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
    [self.graph setTitleTextStyle:textStyleForCurrency(currency)];
    [self.graph setTitlePlotAreaFrameAnchor:CPTRectAnchorTop];
    self.graph.titleDisplacement = CGPointMake( 0.0f, 14.0f );
    
    CGFloat boundsPadding = round(self.bounds.size.width / (CGFloat)40.0);
    
    if (_graph.titleDisplacement.y > 0.0) {
        _graph.paddingTop = _graph.titleDisplacement.y * 3;
    }
    else {
        _graph.paddingTop = boundsPadding;
    }
    _graph.paddingLeft = boundsPadding;
    _graph.paddingRight = boundsPadding;
    _graph.paddingBottom = boundsPadding;
    
    _graph.plotAreaFrame.paddingTop    = kTTGraphWeakSidePadding;
    _graph.plotAreaFrame.paddingRight  = kTTGraphWeakSidePadding;
    _graph.plotAreaFrame.paddingBottom = kTTGraphStrongSidePadding;
    _graph.plotAreaFrame.paddingLeft   = kTTGraphStrongSidePadding;
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
            [style setFontName:titleFontName];
            [style setFontSize:24.f];
            return style;
            break;
        }
    }
    return nil;
}

@end
