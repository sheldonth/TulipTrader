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
#import "NSColor+Hex.h"
#import "TTGoxCurrencyController.h"

#define kTTGraphStrongSidePadding 55.f
#define kTTGraphWeakSidePadding 15.f

#define kTTGraphViewPopupButtonWidth 125.f
#define kTTGraphViewPopupButtonHeight 30.f

@interface TTGraphView()

@property(nonatomic, retain)CPTXYGraph* graph;
@property(nonatomic, retain)CPTGraphHostingView* defaultLayerHostingView;
@property(nonatomic, retain)CPTMutableTextStyle* textStyle;
@property(nonatomic, retain)CPTMutableLineStyle* majorLineStyle;
@property(nonatomic, retain)CPTMutableLineStyle* minorLineStyle;
@property(nonatomic, retain)NSPopUpButton* popUpButton;
@property(nonatomic)CGFloat boundsPadding;

CPTMutableTextStyle* textStyle();

@end

static NSString* titleFontName;
static const NSString* kTTNoCurrencySelectedTitle;

@implementation TTGraphView

/*
 Line Style Enums Of Interest

enum CGLineCap {
    kCGLineCapButt,
    kCGLineCapRound,
    kCGLineCapSquare
};
typedef enum CGLineCap CGLineCap;
 
 enum CGLineJoin {
 kCGLineJoinMiter,
 kCGLineJoinRound,
 kCGLineJoinBevel
 };
 typedef enum CGLineJoin CGLineJoin;
 
 */

+(void)initialize
{
    if (self == [TTGraphView class])
    {
        titleFontName = @"Helvetica-Bold";
        kTTNoCurrencySelectedTitle = @"None";
    }
}

#pragma mark - button selectors

-(void)currencyPopUpDidChange:(id)sender
{
    
}

#pragma mark - internal methods

-(void)setupGraph
{
    if (!_graph)
        {NSException* e = [NSException exceptionWithName:NSInternalInconsistencyException reason:@"No graph object" userInfo:nil]; @throw e;}
    [self.graph applyTheme:[CPTTheme themeNamed:kCPTStocksTheme]];
    [self.graph setFill:[CPTFill fillWithColor:[[CPTColor alloc]initWithCGColor:[NSColor colorWithHexString:@"cccccc"].CGColor]]];
    //    [self.graph setTitle:stringFromCurrency(currency)];
    [self.graph setTitleTextStyle:textStyle()];
    [self.graph setTitlePlotAreaFrameAnchor:CPTRectAnchorTop];
    self.graph.titleDisplacement = CGPointMake( 0.0f, 14.0f );
    
    [self setBoundsPadding:round(self.bounds.size.width / (CGFloat)40.0)];
    
    if (_graph.titleDisplacement.y > 0.0) {
        _graph.paddingTop = _graph.titleDisplacement.y * 3;
    }
    else {
        _graph.paddingTop = self.boundsPadding;
    }
    _graph.paddingLeft = self.boundsPadding;
    _graph.paddingRight = self.boundsPadding;
    _graph.paddingBottom = self.boundsPadding;
    
    _graph.plotAreaFrame.paddingTop    = kTTGraphWeakSidePadding;
    _graph.plotAreaFrame.paddingRight  = kTTGraphWeakSidePadding;
    _graph.plotAreaFrame.paddingBottom = kTTGraphStrongSidePadding;
    _graph.plotAreaFrame.paddingLeft   = kTTGraphStrongSidePadding;
    
    CPTXYAxisSet* axisSet = (CPTXYAxisSet*)[_graph axisSet];
    
    CPTXYAxis* xAxis = axisSet.xAxis;
    xAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    xAxis.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(0);
    xAxis.majorGridLineStyle = self.majorLineStyle;
    xAxis.minorGridLineStyle = self.minorLineStyle;
    xAxis.minorTicksPerInterval = 9;
    xAxis.title = @"Date";
    xAxis.titleOffset = 35.0;
    
    NSNumberFormatter *labelFormatter = [NSNumberFormatter new];
    labelFormatter.numberStyle = NSNumberFormatterNoStyle;
    xAxis.labelFormatter = labelFormatter;

    CPTXYAxis* yAxis = axisSet.yAxis;
    yAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    yAxis.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(0);
    yAxis.majorGridLineStyle = self.majorLineStyle;
    yAxis.minorGridLineStyle = self.minorLineStyle;
    yAxis.minorTicksPerInterval = 3;
    yAxis.labelOffset = 5.0;
    yAxis.title = @"Price";
    yAxis.titleOffset = 30.0;
    yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
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
        if (!_majorLineStyle)
        {
            [self setMajorLineStyle:[CPTMutableLineStyle lineStyle]];
            [_majorLineStyle setLineCap:kCGLineCapRound];
            [_majorLineStyle setLineJoin:kCGLineJoinMiter];
            [_majorLineStyle setLineWidth:0.75f];
            [_majorLineStyle setLineColor:[CPTColor orangeColor]];
        }
        if (!_minorLineStyle)
        {
            [self setMinorLineStyle:[CPTMutableLineStyle lineStyle]];
            [_minorLineStyle setLineCap:kCGLineCapRound];
            [_minorLineStyle setLineJoin:kCGLineJoinMiter];
            [_minorLineStyle setLineWidth:0.25f];
            [_minorLineStyle setLineColor:[CPTColor blackColor]];
        }
        [self setupGraph];
        [self setPopUpButton:[[NSPopUpButton alloc]initWithFrame:(NSRect){CGRectGetWidth(frame) - self.boundsPadding - kTTGraphViewPopupButtonWidth, CGRectGetHeight(frame) - (1.5 * kTTGraphViewPopupButtonHeight), kTTGraphViewPopupButtonWidth, kTTGraphViewPopupButtonHeight} pullsDown:YES]];
        [self.popUpButton addItemWithTitle:(NSString*)kTTNoCurrencySelectedTitle];
        [self.popUpButton addItemsWithTitles:[TTGoxCurrencyController activeCurrencys]];
        [self.popUpButton setAction:@selector(currencyPopUpDidChange:)];
        [self.defaultLayerHostingView addSubview:self.popUpButton];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    
}

#pragma mark - C methods

CPTMutableTextStyle* textStyle()//ForCurrency(TTGoxCurrency currency)
{
            CPTMutableTextStyle* style = [CPTMutableTextStyle textStyle];
            [style setColor:[CPTColor blackColor]];
            [style setFontName:titleFontName];
            [style setFontSize:24.f];
            return style;
}

@end
