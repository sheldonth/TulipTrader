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
#import "TTTextView.h"
#import "TTAppDelegate.h"
#import "Trade.h"

#define kTTGraphStrongSidePadding 55.f
#define kTTGraphWeakSidePadding 15.f

#define kTTGraphViewPopupButtonWidth 125.f
#define kTTGraphViewPopupButtonHeight 30.f

#define kTTGraphViewTimelineButtonWidth 60
#define kTTGraphViewTimelineButtonHeight 25

#define kTTGraphViewPriceUpperYAxisDelta 10


@interface TTDateRange : NSObject

@property(nonatomic, retain)NSDate* openWindowDate;
@property(nonatomic, retain)NSDate* closeWindowDate;

@end

@implementation TTDateRange

+(TTDateRange*)dateRangeWithOpen:(NSDate*)open close:(NSDate*)close
{
    TTDateRange* dateRange = [TTDateRange new];
    [dateRange setOpenWindowDate:open];
    [dateRange setCloseWindowDate:close];
    return dateRange;
}

-(NSString *)description
{
    return RUStringWithFormat(@"\nOpen: %@\nClose: %@", self.openWindowDate, self.closeWindowDate);
}

@end


@interface TTGraphView()

@property(nonatomic, retain)CPTXYGraph* graph;
@property(nonatomic, retain)CPTGraphHostingView* defaultLayerHostingView;
@property(nonatomic, retain)CPTMutableTextStyle* textStyle;
@property(nonatomic, retain)CPTMutableLineStyle* majorLineStyle;
@property(nonatomic, retain)CPTMutableLineStyle* minorLineStyle;
@property(nonatomic, retain)NSPopUpButton* popUpButton;
@property(nonatomic)CGFloat boundsPadding;
@property(nonatomic, retain)NSMutableArray* timelineButtonArray;
@property(nonatomic, retain)TTTextView* loadingLabel;
//@property(nonatomic, retain)CPTScatterPlot* priceInPrimaryCurrencyPlotLine;
@property(nonatomic, retain)dispatch_queue_t databaseOperationQueue;
@property(nonatomic, retain)NSMutableDictionary* tradeDataArrayDictionary;
@property(nonatomic)NSButton* selectedButton;

CPTMutableTextStyle* textStyle();

@end

static NSString* titleFontName;
static const NSString* kTTNoCurrencySelectedTitle;
static NSArray* timeLineLengthButtonArray;
static NSString* defaultTimeLineLength;
static TTAppDelegate* appDelegate;

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
        timeLineLengthButtonArray = @[@"1h", @"1d", @"1m", @"3m", @"6m", @"YTD", @"1y", @"All"];
        defaultTimeLineLength = @"1d";
        appDelegate = (TTAppDelegate*)[[NSApplication sharedApplication]delegate];
    }
}

#pragma mark - CPTDataSource methods (required)
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
//    return numberOfPlotsForDateRange(self.selectedDateRange);
    return self.tradeEventsInTimeFrame.count;
}

#pragma mark - CPTDataSource methods (optional)


//typedef enum _CPTScatterPlotField {
//    CPTScatterPlotFieldX, ///< X values.
//    CPTScatterPlotFieldY  ///< Y values.
//}CPTScatterPlotField;


-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            return @(idx);
            break;
            
        case CPTScatterPlotFieldY:
        {
            Trade* t = [self.tradeEventsInTimeFrame objectAtIndex:idx];
            Trade* t_threadSafe = (Trade*)[appDelegate.managedObjectContext existingObjectWithID:t.objectID error:nil];
            return t_threadSafe.price;
            break;
        }
        default:
            return @(0);
            break;
    }
}

#pragma mark - CPTSDelegate methods (required)

#pragma mark - CPTDelegate methods (options)

#pragma mark - C Methods

/*
 @purpose: Given the knowledge of the # of plots, and the timeInterval conferred to the user, return a TTDateRange for that unit.
 */

TTDateRange* dateRangeForIndexAndSelectedDateRange(NSUInteger recordIndex, TTGraphViewDateRange selectedDateRange)
{
    NSCalendar* gregorianCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    TTDateRange* dateRange = nil;
    NSInteger timeRelativePlotsBeforeNow = (-1 * (numberOfPlotsForDateRange(selectedDateRange) - recordIndex));
    NSDateComponents* windowOpenDateComponents = [NSDateComponents new];
    NSDateComponents* windowCloseDateComponents = [NSDateComponents new];
    switch (selectedDateRange) {
        case TTGraphViewDateRangeNone:
        {
            NSException* e = [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Asked For A TTDateRange when TTGraphViewDateRangeNone is the selected Date Range" userInfo:nil];
            @throw e;
            break;
        }
            
        case TTGraphViewDateRangeOneHour: // One hour has sixty plots, the window is (60-recordIndex) minutes before now
            [windowOpenDateComponents setMinute:timeRelativePlotsBeforeNow];
            [windowCloseDateComponents setMinute:(timeRelativePlotsBeforeNow + 1)];
            break;
            
        case TTGraphViewDateRangeOneDay:
            [windowOpenDateComponents setHour:timeRelativePlotsBeforeNow];
            [windowCloseDateComponents setHour:(timeRelativePlotsBeforeNow + 1)];
            break;
            
        case TTGraphViewDateRangeOneMonth:
        case TTGraphViewDateRangeThreeMonths:
        case TTGraphViewDateRangeSixMonths:
        case TTGraphViewDateRangeYearToDate:
        case TTGraphViewDateRangeOneYear:
            [windowOpenDateComponents setDay:timeRelativePlotsBeforeNow];
            [windowCloseDateComponents setDay:(timeRelativePlotsBeforeNow + 1)];
            break;
            
        case TTGraphViewDateRangeAll:
            RUDLog(@"Still need to write the math for subdividing data into DateRangeAll!");
            break;
    }
    NSDate* windowOpen = [gregorianCalendar dateByAddingComponents:windowOpenDateComponents toDate:[NSDate date] options:0];
    NSDate* windowClose = [gregorianCalendar dateByAddingComponents:windowCloseDateComponents toDate:[NSDate date] options:0];
    dateRange = [TTDateRange dateRangeWithOpen:windowOpen close:windowClose];
    return dateRange;
}

CPTMutableTextStyle* textStyle()//ForCurrency(TTGoxCurrency currency)
{
    CPTMutableTextStyle* style = [CPTMutableTextStyle textStyle];
    [style setColor:[CPTColor blackColor]];
    [style setFontName:titleFontName];
    [style setFontSize:24.f];
    return style;
}

NSUInteger numberOfPlotsForDateRange(TTGraphViewDateRange range)
{
    switch (range) {
        case TTGraphViewDateRangeNone:
            return 0;
            break;
            
        case TTGraphViewDateRangeOneHour:
            return 60;
            break;
            
        case TTGraphViewDateRangeOneDay:
            return 24;
            break;
        
        case TTGraphViewDateRangeOneMonth:
            return 30;
            break;
            
        case TTGraphViewDateRangeThreeMonths:
            return 90;
            break;
            
        case TTGraphViewDateRangeSixMonths:
            return 180;
            break;
            
        case TTGraphViewDateRangeYearToDate:
        {
            NSDate* now = [NSDate date];
            NSCalendar* gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents* components = [gregorian components:NSDayCalendarUnit fromDate:now];
            return components.day;
            break;
        }
        
        case TTGraphViewDateRangeOneYear:
            return 365;
            break;
            
        case TTGraphViewDateRangeAll:
            return 500; // This is kinda arbitrary, how many units do you divide all data into?
            break;
            
        default:
            return 0;
            break;
    }
}

#pragma mark - button selectors

-(NSDate*)startDateForDateRange:(TTGraphViewDateRange)dateRange
{
    NSDate* now = [NSDate date];
    NSCalendar* gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = [NSDateComponents new];
    switch (dateRange) {
        case TTGraphViewDateRangeNone:
            return now;
            break;
            
        case TTGraphViewDateRangeOneHour:
            [components setHour:-1];
            return [gregorian dateByAddingComponents:components toDate:now options:0];
            break;
            
        case TTGraphViewDateRangeOneDay:
            [components setDay:-1];
            return [gregorian dateByAddingComponents:components toDate:now options:0];
            break;
            
        case TTGraphViewDateRangeOneMonth:
            [components setMonth:-1];
            return [gregorian dateByAddingComponents:components toDate:now options:0];
            break;
            
        case TTGraphViewDateRangeThreeMonths:
            [components setMonth:-3];
            return [gregorian dateByAddingComponents:components toDate:now options:0];
            break;
            
        case TTGraphViewDateRangeSixMonths:
            [components setMonth:-6];
            return [gregorian dateByAddingComponents:components toDate:now options:0];
            break;
            
        case TTGraphViewDateRangeYearToDate:
        {
            components = [gregorian components:NSYearCalendarUnit fromDate:now];
            [components setMonth:1];
            [components setDay:1];
            NSDate* d = [gregorian dateFromComponents:components];
            return d;
            break;
        }
        case TTGraphViewDateRangeOneYear:
            [components setYear:-1];
            return [gregorian dateByAddingComponents:components toDate:now options:0];
            break;
            
        case TTGraphViewDateRangeAll:
            return [NSDate date];
            break;
            
        default:
            return [NSDate date];
            break;
    }
}

-(void)currencyPopUpDidChange:(NSPopUpButton*)sender
{
    [sender setTitle:sender.titleOfSelectedItem];
    [self setCurrency:currencyFromString(sender.titleOfSelectedItem)];
    [self addCurrencyToGraph:currencyFromString(sender.titleOfSelectedItem)];
}

-(void)timelineButtonClicked:(NSButton*)sender
{
    [self setSelectedButton:sender];
    NSString* buttonTitle = sender.title;
    if ([buttonTitle isEqualToString:@"1h"])
        [self setSelectedDateRange:TTGraphViewDateRangeOneHour];
    else if ([buttonTitle isEqualToString:@"1d"])
        [self setSelectedDateRange:TTGraphViewDateRangeOneDay];
    else if ([buttonTitle isEqualToString:@"1m"])
        [self setSelectedDateRange:TTGraphViewDateRangeOneMonth];
    else if ([buttonTitle isEqualToString:@"3m"])
        [self setSelectedDateRange:TTGraphViewDateRangeThreeMonths];
    else if ([buttonTitle isEqualToString:@"6m"])
        [self setSelectedDateRange:TTGraphViewDateRangeSixMonths];
    else if ([buttonTitle isEqualToString:@"1y"])
        [self setSelectedDateRange:TTGraphViewDateRangeOneYear];
    else if ([buttonTitle isEqualToString:@"YTD"])
        [self setSelectedDateRange:TTGraphViewDateRangeYearToDate];
    else if ([buttonTitle isEqualToString:@"All"])
        [self setSelectedDateRange:TTGraphViewDateRangeAll];
    else
        [self setSelectedDateRange:TTGraphViewDateRangeNone];
    [self.timelineButtonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj == sender)
            [obj setState:NSOnState];
        else
            [obj setState:NSOffState];
    }];
    [self.graph reloadData];
}

#pragma mark - internal methods

/*
    Fetches the median price of a set of trades which occured during a timeinterval
    Each timeinterval is an index of the numberOfRecords: datasource method
 */

-(NSNumber*)yValueForRecordIndex:(NSUInteger)index
{
    // write a fetch request that gets the median price over the time interval for the index.
    
    NSExpression* keyPathExpression = [NSExpression expressionForKeyPath:@"price"];
    NSExpression* maxExpression = [NSExpression expressionForFunction:@"average:" arguments:@[keyPathExpression]];
    
    NSExpressionDescription* expressionDescription = [NSExpressionDescription new];
    [expressionDescription setName:@"medianPrice"];
    [expressionDescription setExpression:maxExpression];
    [expressionDescription setExpressionResultType:NSDoubleAttributeType];
    
    NSFetchRequest* medianFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Trade"];
    TTDateRange* range = dateRangeForIndexAndSelectedDateRange(index, self.selectedDateRange);
    [medianFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(date >= %@) AND (date =< %@) AND (currency == %@) AND (real_boolean == %@)", range.openWindowDate, range.closeWindowDate, numberFromCurrency(self.currency), @(1)]];

//    [medianFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(date >= %@) AND (date =< %@) AND (currency == %@)", range.openWindowDate, range.closeWindowDate, numberFromCurrency(<#TTGoxCurrency currency#>) self.currency]];
    
    [medianFetchRequest setPropertiesToFetch:@[expressionDescription]]; // If you wanted to fetch multiple expression descriptions on different properties, add it to this array.
    [medianFetchRequest setResultType:NSDictionaryResultType];
    NSError* e = nil;
    
    // Create an alternate fetch that gets the object list for now
//    NSFetchRequest* f = [NSFetchRequest fetchRequestWithEntityName:@"Trade"];
//    [f setPredicate:[NSPredicate predicateWithFormat:@"(date > %@) AND (date < %@)  AND (currency == %@) AND (real_boolean == %@)", range.openWindowDate, range.closeWindowDate, numberFromCurrency(self.currency), @(1)]];
//    NSArray* realObjectArray = [appDelegate.managedObjectContext executeFetchRequest:f error:nil];
    
    // If the fetch happens on thread 1, use the appdelegate's MOC -- as it is going to happen here.
    NSArray* dataSet = [appDelegate.managedObjectContext executeFetchRequest:medianFetchRequest error:&e];
    if (e)
        RUDLog(@"Error running fetch request for timerange %@", range);
    NSDictionary* d = [dataSet lastObject];
    
    if (![[d allKeys] count])
        return @(0);
    else
        return [d objectForKey:@"medianPrice"];
}


-(void)loadDataForCurrency:(TTGoxCurrency)currency
{
    [self showLoadingLabel:YES];
    if (!_databaseOperationQueue)
        [self setDatabaseOperationQueue:dispatch_queue_create("co.resplendent.graphLoadingQueue", NULL)];
        NSDate* d = [self startDateForDateRange:self.selectedDateRange];
        NSPredicate* p = [NSPredicate predicateWithFormat:@"(date > %@) AND (currency == %@) AND (real_boolean == %@)", d, numberFromCurrency(currency), @(YES)];
        [Trade computeFunctionNamed:@"max:" onTradePropertyWithName:@"price" optionalPredicate:p completion:^(NSNumber *computedResult) {
            NSUInteger maxPrice = [computedResult unsignedIntegerValue] + kTTGraphViewPriceUpperYAxisDelta;
            [Trade findTradesWithPredicate:p completion:^(NSArray *results) {
                _tradeEventsInTimeFrame = results;
                dispatch_async(dispatch_get_main_queue(), ^{
                    CPTScatterPlot* currencyPlot = [CPTScatterPlot new];
                    [currencyPlot setDataSource:self];
                    [currencyPlot setDelegate:self];
                    [currencyPlot setIdentifier:stringFromCurrency(currency)];
                    [currencyPlot setCachePrecision:CPTPlotCachePrecisionAuto];
                    
                    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
                    
                    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(numberOfPlotsForDateRange(self.selectedDateRange))];
                    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(maxPrice)];
                    
                    CPTMutableLineStyle *lineStyle = [currencyPlot.dataLineStyle mutableCopy];
                    lineStyle.lineWidth = 2.0;
                    lineStyle.lineColor = [CPTColor colorWithCGColor:colorForCurrency(currency).CGColor];
                    currencyPlot.dataLineStyle = lineStyle;
                    [self.graph addPlot:currencyPlot];
                    [self setNeedsDisplay:YES];
                });

            }];
        }];
}

                   


-(void)showLoadingLabel:(BOOL)show
{
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showLoadingLabel:show];
            return ;
        });
    }
    show ? [self.defaultLayerHostingView addSubview:_loadingLabel] : [self.loadingLabel removeFromSuperview];
}

-(void)removeCurrencyFromGraph:(TTGoxCurrency)currency
{
    CPTPlot* p = [self.graph plotWithIdentifier:stringFromCurrency(currency)];
    [self.graph removePlot:p];
}

-(void)addCurrencyToGraph:(TTGoxCurrency)currency
{
    [self loadDataForCurrency:currency];
}

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
    xAxis.minorTicksPerInterval = 19;
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
//    yAxis.title = @"Price";
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
//            [self addSubview:_defaultLayerHostingView];
        }
        if (!_graph)
        {
            [self setGraph:[[CPTXYGraph alloc]initWithFrame:self.bounds]];
            [_defaultLayerHostingView setHostedGraph:_graph];
//            CGRect
//            [self.graph layoutAndRenderInContext:<#(CGContextRef)#>]
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
        [self.popUpButton setAutoenablesItems:YES];
        [self.popUpButton setAction:@selector(currencyPopUpDidChange:)];
        [self.popUpButton setTarget:self];
//        [self.defaultLayerHostingView addSubview:self.popUpButton];
        [self addSubview:self.popUpButton];
        
        [self setLoadingLabel:[[TTTextView alloc]initWithFrame:(NSRect){CGRectGetMidX(frame), CGRectGetMidY(frame), 200, 100}]];
        [self.loadingLabel setBackgroundColor:[NSColor clearColor]];
        [self.loadingLabel setString:@"Loading"];
        [self.defaultLayerHostingView addSubview:_loadingLabel];
        
        _timelineButtonArray = [NSMutableArray array];
        
        _tradeDataArrayDictionary = [NSMutableDictionary dictionary];
        
        _plots = [NSMutableArray array];
        
        [timeLineLengthButtonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSButton* btn = [NSButton new];
            [btn setButtonType:NSPushOnPushOffButton];
            [btn setBezelStyle:NSRoundRectBezelStyle];
            [btn setFrame:NSMakeRect(self.boundsPadding + (idx * kTTGraphViewTimelineButtonWidth), CGRectGetHeight(frame) - (1.5 * kTTGraphViewTimelineButtonHeight), kTTGraphViewTimelineButtonWidth, kTTGraphViewTimelineButtonHeight)];
            [btn setTitle:[timeLineLengthButtonArray objectAtIndex:idx]];
            [btn setAction:@selector(timelineButtonClicked:)];
            [btn setTarget:self];
            [self.timelineButtonArray addObject:btn];
//            [self.defaultLayerHostingView addSubview:btn];
            [self addSubview:btn];
        }];
        [[self.timelineButtonArray objectAtIndex:0]setState:NSOnState];
        [self setSelectedButton:[self.timelineButtonArray objectAtIndex:0]];
    }
    return self;
}

-(NSImage*)imageRepresentingCurrentObjects
{
    NSRect imageFrame = self.frame;
    NSView* imageView = [[NSView alloc]initWithFrame:imageFrame];
    [imageView setWantsLayer:YES];
    if (self.defaultLayerHostingView)
    {
        [imageView addSubview:self.defaultLayerHostingView];
    }
    else
    {NSException* e = [NSException exceptionWithName:NSInternalInconsistencyException reason:RUStringWithFormat(@"No defaultLayerHostingView") userInfo:nil];@throw e;}

    CGSize boundingSize = imageFrame.size;
    NSBitmapImageRep* bitmapImageRep = [[NSBitmapImageRep alloc]initWithBitmapDataPlanes:NULL
                                                                              pixelsWide:boundingSize.width
                                                                              pixelsHigh:boundingSize.height
                                                                           bitsPerSample:8
                                                                         samplesPerPixel:4
                                                                                hasAlpha:YES
                                                                                isPlanar:NO
                                                                          colorSpaceName:NSCalibratedRGBColorSpace
                                                                             bytesPerRow:(NSInteger)boundingSize.width * 4
                                                                            bitsPerPixel:32];
    NSGraphicsContext* bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmapImageRep];
    
    CGContextRef context = (CGContextRef)[bitmapContext graphicsPort];
    CGContextClearRect(context, CGRectMake(0.f, 0.f, boundingSize.width, boundingSize.height));
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldSmoothFonts(context, false);
    [imageView.layer renderInContext:context];
    CGContextFlush(context);
    
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//    CGContextRef contextReference = [[NSGraphicsContext currentContext]graphicsPort];
//    [self.graph.allPlots enumerateObjectsUsingBlock:^(CPTPlot* obj, NSUInteger idx, BOOL *stop) {
//        [obj layoutAndRenderInContext:contextReference];
//    }];
//}

@end
