//
//  TTDepthStackView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/13/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTDepthStackView.h"
#import "TTGoxHTTPController.h"
#import "RUConstants.h"
#import "TTDepthOrder.h"
#import "NSColor+Hex.h"
#import "RUClassOrNilUtil.h"

@interface TTDepthPositionValue : NSObject

@property(nonatomic, retain)NSNumber* depth;
@property(nonatomic, retain)NSNumber* orders;
@property(nonatomic, retain)NSNumber* rangeCenter;

@end

@implementation TTDepthPositionValue

-(NSString *)description
{
    return RUStringWithFormat(@"%@ in %@ orders at %@", self.depth, self.orders, self.rangeCenter);
}

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setDepth:@(0)];
        [self setOrders:@(0)];
        [self setRangeCenter:@(0)];
    }
    return self;
}

@end

@interface TTDepthStackView ()
{
    NSNumber* lowestBid;
    NSNumber* highestBid;
    NSNumber* lowestAsk;
    NSNumber* highestAsk;
    NSNumber* assetDelta;
    NSNumber* assetMidpoint;
    NSNumber* largestBidOrderSize;
    NSNumber* largestAskOrderSize;
    NSNumber* bidPositionsDelta;
    NSNumber* askPositionsDelta;
    NSNumber* maxAskPositionDepth;
    NSNumber* maxBidPositionDepth;
    NSNumber* maxGeneralPositionDepth;
    NSRect graphRectPtr;
    NSBezierPath* containingRectPath;
}
@property(nonatomic, retain)NSArray* bids;
@property(nonatomic, retain)NSArray* asks;
@property(nonatomic, retain)NSMutableArray* bidsPositionValues;
@property(nonatomic, retain)NSMutableArray* asksPositionValues;
@property(nonatomic, retain)NSDictionary* maxMinTicks;
@property(nonatomic, retain)NSButton* zoomIn;
@property(nonatomic, retain)NSButton* zoomOut;
@property(nonatomic, retain)NSMutableArray* drawablePaths;
@property(nonatomic, retain)NSBezierPath* xAxisCrosshair;
@property(nonatomic, retain)NSBezierPath* yAxisCrosshair;
@property(nonatomic, retain)NSTrackingArea* trackingArea;

@property(nonatomic, retain)NSMutableArray* depthBidCircleBezierPathsArray;
@property(nonatomic, retain)NSMutableArray* depthAskCircleBezierPathsArray;

-(NSInteger)depthSamplesForZoom;

@end

@implementation TTDepthStackView

#define depthChartBottomInset 5.f
#define depthChartTopInset 5.f
#define depthChartLeftSideInsets 17.f
#define depthChartRightSideInsets 17.f

#define leadingElementsToDrawBlack 3

#define numberOfDepthSamples 50

#pragma mark - public methods, observing streaming depth changes

-(void)processDepthDictionary:(NSDictionary*)d
{
    if (!self.hasSeededDepthData)
        return;

    TTDepthOrder* deltaOrder = [TTDepthOrder new];
    [deltaOrder setAmount:@(kRUStringOrNil([d objectForKey:@"volume"]).doubleValue)];
    [deltaOrder setPrice:@(kRUStringOrNil([d objectForKey:@"price"]).doubleValue)];

    NSString* microsecondTimeString = [d objectForKey:@"now"];
    [deltaOrder setTime:[NSDate dateWithTimeIntervalSince1970:(microsecondTimeString.doubleValue / 1000000)]];
    [deltaOrder setTimeStampStr:[d objectForKey:@"now"]];
    
    NSString* typeStr = [d objectForKey:@"type_str"];
    
    if ([typeStr isEqualToString:@"ask"])
        [deltaOrder setDepthOrderType:(TTDepthOrderTypeAsk)];
    else if ([typeStr isEqualToString:@"bid"])
        [deltaOrder setDepthOrderType:(TTDepthOrderTypeBid)];
    else
        [deltaOrder setDepthOrderType:(TTDepthOrderTypeNone)];
    
//    RUDLog(@"%i %@ at %@", deltaOrder.depthOrderType, deltaOrder.amount.stringValue, deltaOrder.price.stringValue);
//    return;
    
    if (self.currency == TTGoxCurrencyUSD)
    {
        switch (deltaOrder.depthOrderType) {
            case TTDepthOrderTypeAsk:
            {
                __block BOOL isFound = NO;
                [self.asks enumerateObjectsUsingBlock:^(TTDepthOrder* order, NSUInteger idx, BOOL *stop) {
                    if ([order isAbsoluteTermsEqualToDepthOrder:deltaOrder])
                    {
                        RUDLog(@"Found: %@ %@ at %@", [d objectForKey:@"type_str"], [d objectForKey:@"volume"], [d objectForKey:@"price"]);
                        isFound = YES;
                        *stop = YES;
                    }
                }];
                if (!isFound)
                    RUDLog(@"Failed on ask");
                break;
            }
            case TTDepthOrderTypeBid:
            {
                __block BOOL isFound = NO;
                [self.bids enumerateObjectsUsingBlock:^(TTDepthOrder* order, NSUInteger idx, BOOL *stop) {
                    if ([order isAbsoluteTermsEqualToDepthOrder:deltaOrder])
                    {
                        RUDLog(@"%@ %@ at %@", [d objectForKey:@"type_str"], [d objectForKey:@"volume"], [d objectForKey:@"price"]);
                        isFound = YES;
                        *stop = YES;
                    }
                }];
                if (!isFound)
                    RUDLog(@"Failed on bid");
            }
            default:
                break;
        }
    }
}

#pragma mark - mouse events

-(void)mouseUp:(NSEvent *)theEvent
{
    
}

-(void)mouseDown:(NSEvent *)theEvent
{
    
}

-(void)mouseEntered:(NSEvent *)theEvent
{
    NSPoint eventLocation = [theEvent locationInWindow];
    NSPoint convertedPt = [self convertPoint:eventLocation fromView:nil];
    
    NSBezierPath* xCross = [NSBezierPath bezierPath];
    [xCross moveToPoint:(NSPoint){CGRectGetMinX(graphRectPtr), convertedPt.y}];
    [xCross lineToPoint:(NSPoint){CGRectGetMaxX(graphRectPtr), convertedPt.y}];
    [self setXAxisCrosshair:xCross];
    
    NSBezierPath* yCross = [NSBezierPath bezierPath];
    [yCross moveToPoint:(NSPoint){convertedPt.x, CGRectGetMinY(graphRectPtr)}];
    [yCross lineToPoint:(NSPoint){convertedPt.x, CGRectGetMaxY(graphRectPtr)}];
    [self setYAxisCrosshair:yCross];

    [self setNeedsDisplay:YES];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    [self.xAxisCrosshair removeAllPoints];
    [self.yAxisCrosshair removeAllPoints];
    [self setXAxisCrosshair:nil];
    [self setYAxisCrosshair:nil];
    [self setNeedsDisplay:YES];
}

-(void)mouseMoved:(NSEvent *)theEvent
{
    NSPoint eventLocation = [theEvent locationInWindow];
    NSPoint convertedPt = [self convertPoint:eventLocation fromView:nil];

    if (!self.xAxisCrosshair)
        [self setXAxisCrosshair:[NSBezierPath bezierPath]];
    [self.xAxisCrosshair removeAllPoints];
    [self.xAxisCrosshair moveToPoint:(NSPoint){CGRectGetMinX(graphRectPtr), convertedPt.y}];
    [self.xAxisCrosshair lineToPoint:(NSPoint){CGRectGetMaxX(graphRectPtr), convertedPt.y}];

    if (!self.yAxisCrosshair)
        [self setYAxisCrosshair:[NSBezierPath bezierPath]];
    [self.yAxisCrosshair removeAllPoints];
    [self.yAxisCrosshair moveToPoint:(NSPoint){convertedPt.x, CGRectGetMinY(graphRectPtr)}];
    [self.yAxisCrosshair lineToPoint:(NSPoint){convertedPt.x, CGRectGetMaxY(graphRectPtr)}];
    
    NSMutableArray* crossHairHits = [NSMutableArray array];
    switch (self.chartingProcedure)
    {
        case TTDepthViewChartingProcedureSampling:
        {
            [self.depthAskCircleBezierPathsArray enumerateObjectsUsingBlock:^(NSBezierPath* obj, NSUInteger idx, BOOL *stop) {
                if ([obj containsPoint:convertedPt])
                    [crossHairHits addObject:obj];
            }];
            [self.depthBidCircleBezierPathsArray enumerateObjectsUsingBlock:^(NSBezierPath* obj, NSUInteger idx, BOOL *stop) {
                if ([obj containsPoint:convertedPt])
                    [crossHairHits addObject:obj];
            }];
            break;
        }
            
        case TTDepthViewChartingProcedureAllOrders:
        {
            [self.depthAskCircleBezierPathsArray enumerateObjectsUsingBlock:^(NSBezierPath* obj, NSUInteger idx, BOOL *stop) {
                if ([obj containsPoint:convertedPt])
                    [crossHairHits addObject:obj];
            }];
            [self.depthBidCircleBezierPathsArray enumerateObjectsUsingBlock:^(NSBezierPath* obj, NSUInteger idx, BOOL *stop) {
                if ([obj containsPoint:convertedPt])
                    [crossHairHits addObject:obj];
            }];
            break;
        }
        default:
            break;
    }
    
    [self setNeedsDisplay:YES];
}

-(void)cursorUpdate:(NSEvent *)event
{
    
}

-(NSInteger)depthSamplesForZoom
{
    return numberOfDepthSamples * self.zoomLevel;
}

-(void)setZoomLevel:(NSInteger)zoomLevel
{
    _zoomLevel = zoomLevel;
}

NSString* stringForPriceNumber(NSNumber* priceNumber)
{
    if (priceNumber.floatValue < 100.f)
        return RUStringWithFormat(@"%.1f", priceNumber.floatValue);
    else
        return RUStringWithFormat(@"%.0f", priceNumber.floatValue);
}

NSDictionary* attributeDictionaryForGraphYLabel()
{
    return @{NSFontAttributeName : [NSFont systemFontOfSize:7.f]};
}

NSDictionary* attributeDictionaryForGraphXLabel()
{
    return [NSDictionary dictionary];   
}

void drawLine(CGContextRef context, CGFloat lineWidth, CGColorRef lineColor, CGPoint startPoint, CGPoint endPoint)
{
    CGContextSetLineWidth(context, lineWidth);
    
    CGContextSetStrokeColorWithColor(context, lineColor);
    
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    
    CGContextStrokePath(context);
}

-(void)reload
{
    if (!_isReloading)
        [self loadDepthForCurrency:self.currency];
}

-(void)processData
{
    [self setBidsPositionValues:[NSMutableArray array]];
    [self setAsksPositionValues:[NSMutableArray array]];
    lowestBid = [[self.bids objectAtIndex:0]price];
    highestBid = [[self.bids lastObject]price];
    lowestAsk = [[self.asks objectAtIndex:0]price];
    highestAsk = [[self.asks lastObject]price];
    assetDelta = @(highestAsk.floatValue - lowestBid.floatValue);
    assetMidpoint = @((highestAsk.floatValue + lowestBid.floatValue) / 2);
    largestBidOrderSize = [[[self.bids sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"amount" ascending:NO]]]objectAtIndex:0] amount];
    largestAskOrderSize = [[[self.asks sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"amount" ascending:NO]]]objectAtIndex:0] amount];
    bidPositionsDelta = @((highestBid.floatValue - lowestBid.floatValue) / self.depthSamplesForZoom);
    askPositionsDelta = @((highestAsk.floatValue - lowestAsk.floatValue) / self.depthSamplesForZoom);
    
    for (int i = 0; i < self.depthSamplesForZoom; i++) {
        NSNumber* lowEnd = @(lowestBid.floatValue + (bidPositionsDelta.floatValue * i));
        NSNumber* highEnd = @(lowestBid.floatValue + (bidPositionsDelta.floatValue * (i + 1)));
        NSPredicate* pred = [NSPredicate predicateWithFormat:@"price BETWEEN %@", @[lowEnd, highEnd]];
        NSArray* bidsInRange = [self.bids filteredArrayUsingPredicate:pred];
        TTDepthPositionValue* depthPositionValue = [[TTDepthPositionValue alloc]init];
        [depthPositionValue setRangeCenter:@((highEnd.floatValue + lowEnd.floatValue) / 2)];
        [bidsInRange enumerateObjectsUsingBlock:^(TTDepthOrder* obj, NSUInteger idx, BOOL *stop) {
            [depthPositionValue setDepth:@(depthPositionValue.depth.floatValue + obj.amount.floatValue)];
            [depthPositionValue setOrders:@(depthPositionValue.orders.floatValue + 1)];
        }];
        [self.bidsPositionValues addObject:depthPositionValue];
    };
    
    TTDepthPositionValue* maxBidDepth = [[self.bidsPositionValues sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"depth" ascending:NO]]]objectAtIndex:0];
    maxBidPositionDepth = [maxBidDepth depth];
    
    for (int i = 0; i < self.depthSamplesForZoom; i++) {
        NSNumber* lowEnd = @(lowestAsk.floatValue + (askPositionsDelta.floatValue * i));
        NSNumber* highEnd = @(lowestAsk.floatValue + (askPositionsDelta.floatValue * (i + 1)));
        NSPredicate* pred = [NSPredicate predicateWithFormat:@"price BETWEEN %@", @[lowEnd, highEnd]];
        NSArray* asksInRange = [self.asks filteredArrayUsingPredicate:pred];
        TTDepthPositionValue* depthPositionValue = [[TTDepthPositionValue alloc]init];
        [depthPositionValue setRangeCenter:@((highEnd.floatValue + lowEnd.floatValue) / 2)];
        [asksInRange enumerateObjectsUsingBlock:^(TTDepthOrder* obj, NSUInteger idx, BOOL *stop) {
            [depthPositionValue setDepth:@(depthPositionValue.depth.floatValue + obj.amount.floatValue)];
            [depthPositionValue setOrders:@(depthPositionValue.orders.floatValue + 1)];
        }];
        [self.asksPositionValues addObject:depthPositionValue];
    }
    TTDepthPositionValue* maxAskDepth = [[self.asksPositionValues sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"depth" ascending:NO]]]objectAtIndex:0];
    maxAskPositionDepth = [maxAskDepth depth];
    
    if (maxAskPositionDepth.floatValue > maxBidPositionDepth.floatValue)
        maxGeneralPositionDepth = maxAskPositionDepth;
    else
        maxGeneralPositionDepth = maxBidPositionDepth;
}

-(void)loadDepthForCurrency:(TTGoxCurrency)curr
{
    _isReloading = YES;
    if (curr == TTGoxCurrencyUSD)
    {
    [[TTGoxHTTPController sharedInstance]getDepthForCurrency:curr withCompletion:^(NSArray *bids, NSArray *asks, NSDictionary *maxMinTicks) {
        _isReloading = NO;
        [self setBids:bids];
        [self setAsks:asks];
        [self setMaxMinTicks:maxMinTicks];
        [self processData];
        [self setHasSeededDepthData:YES];
        [self setLineDataIsDirty:YES];
        [self setNeedsDisplay:YES];
    } withFailBlock:^(NSError *e) {
        RUDLog(@"reload failed on currency %@",stringFromCurrency(self.currency));
        _isReloading = NO;
//        [NSTimer scheduledTimerWithTimeInterval:arc4random()%3 target:self selector:@selector(reload) userInfo:nil repeats:NO];
    }];
    }
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setHasSeededDepthData:NO];
        [self setZoomLevel:1];
        [self setChartingProcedure:(TTDepthViewChartingProcedureSampling)];
        graphRectPtr = (NSRect){depthChartLeftSideInsets, depthChartBottomInset, CGRectGetWidth(frame) - (depthChartLeftSideInsets + depthChartRightSideInsets), CGRectGetHeight(frame) - (depthChartBottomInset + depthChartTopInset)};
        containingRectPath = [NSBezierPath bezierPathWithRect:graphRectPtr];
        
        [self setTrackingArea:[[NSTrackingArea alloc]initWithRect:graphRectPtr options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved+NSTrackingActiveInKeyWindow) owner:self userInfo:nil]];
        [self addTrackingArea:_trackingArea];
    }
    
    return self;
}

-(void)setFrame:(NSRect)frameRect
{
    graphRectPtr = (NSRect){depthChartLeftSideInsets, depthChartBottomInset, CGRectGetWidth(frameRect) - (depthChartLeftSideInsets + depthChartRightSideInsets), CGRectGetHeight(frameRect) - (depthChartBottomInset + depthChartTopInset)};
    containingRectPath = [NSBezierPath bezierPathWithRect:graphRectPtr];
    [super setFrame:frameRect];
}

-(void)setCurrency:(TTGoxCurrency)currency
{
    [self willChangeValueForKey:@"currency"];
    _currency = currency;
    [self didChangeValueForKey:@"currency"];
}

-(void)drawDepthTableInRect:(NSRect)dirtyRect graphRect:(NSRect)graphRect pixelsPerAssetUnitDelta:(CGFloat)pixelsPerAssetDeltaUnit
{
    [self setDrawablePaths:[NSMutableArray array]];
    
    [self setDepthAskCircleBezierPathsArray:[NSMutableArray array]];
    [self setDepthBidCircleBezierPathsArray:[NSMutableArray array]];

    CGFloat dashArray[2];
    dashArray[0] = 2;
    dashArray[1] = 2;
    
    NSBezierPath* bidLine = [NSBezierPath bezierPath];
    [bidLine setLineDash:dashArray count:2 phase:0];
    [bidLine moveToPoint:(NSPoint){CGRectGetMinX(graphRect), (pixelsPerAssetDeltaUnit * (highestBid.floatValue - lowestBid.floatValue)) + depthChartBottomInset}];
    [bidLine lineToPoint:(NSPoint){CGRectGetMidX(graphRect), (pixelsPerAssetDeltaUnit * (highestBid.floatValue - lowestBid.floatValue)) + depthChartBottomInset}];
    [_drawablePaths addObject:bidLine];
    
    NSBezierPath* askLine = [NSBezierPath bezierPath];
    [askLine setLineDash:dashArray count:2 phase:0];
    [askLine moveToPoint:(NSPoint){CGRectGetMaxX(graphRect), (pixelsPerAssetDeltaUnit * (lowestAsk.floatValue - lowestBid.floatValue)) + depthChartBottomInset}];
    [askLine lineToPoint:(NSPoint){CGRectGetMaxX(graphRect) - (CGRectGetWidth(graphRect) / 2), (pixelsPerAssetDeltaUnit * (lowestAsk.floatValue - lowestBid.floatValue)) + depthChartBottomInset}];
    [_drawablePaths addObject:askLine];
    
    NSBezierPath* rectMidLine = [NSBezierPath bezierPath];
    [rectMidLine moveToPoint:(NSPoint){CGRectGetMidX(graphRect), CGRectGetMaxY(graphRect)}];
    [rectMidLine lineToPoint:(NSPoint){CGRectGetMidX(graphRect), CGRectGetMinY(graphRect)}];
    [_drawablePaths addObject:rectMidLine];
    
    switch (self.chartingProcedure) {
        case TTDepthViewChartingProcedureSampling:
        {
            [self.bidsPositionValues enumerateObjectsUsingBlock:^(TTDepthPositionValue* obj, NSUInteger idx, BOOL *stop) {
                if (obj.orders.intValue)
                {
                    NSBezierPath* bidDepthLine = [NSBezierPath bezierPath];
                    [bidDepthLine setLineWidth:1.0f];
                    [bidDepthLine moveToPoint:(NSPoint){CGRectGetMidX(graphRect), ((obj.rangeCenter.floatValue - lowestBid.floatValue) * pixelsPerAssetDeltaUnit) + depthChartBottomInset}];
                    [bidDepthLine lineToPoint:(NSPoint){CGRectGetMidX(graphRect) - ((obj.depth.floatValue / maxGeneralPositionDepth.floatValue) * (CGRectGetWidth(graphRect) / 2)), ((obj.rangeCenter.floatValue - lowestBid.floatValue) * pixelsPerAssetDeltaUnit) + depthChartBottomInset}];
                    [_drawablePaths addObject:bidDepthLine];
                    if (NSEqualPoints(bidDepthLine.currentPoint, NSZeroPoint))
                        RUDLog(@"Biddepthline has a zero point");
                    NSBezierPath* bidLineCircle = [NSBezierPath bezierPathWithOvalInRect:(NSRect){bidDepthLine.currentPoint.x - 2, bidDepthLine.currentPoint.y - 2, 4, 4}];
                    [_drawablePaths addObject:bidLineCircle];
                    [self.depthBidCircleBezierPathsArray addObject:bidLineCircle];
                }
            }];
            [self.asksPositionValues enumerateObjectsUsingBlock:^(TTDepthPositionValue* obj, NSUInteger idx, BOOL *stop) {
                if (obj.orders.intValue)
                {
                    NSBezierPath* askDepthLine = [NSBezierPath bezierPath];
                    [askDepthLine setLineWidth:1.0f];
                    [askDepthLine moveToPoint:(NSPoint){CGRectGetMidX(graphRect), ((obj.rangeCenter.floatValue - lowestBid.floatValue) * pixelsPerAssetDeltaUnit) + depthChartBottomInset}];
                    [askDepthLine lineToPoint:(NSPoint){CGRectGetMidX(graphRect) + ((obj.depth.floatValue / maxGeneralPositionDepth.floatValue) * (CGRectGetWidth(graphRect) / 2)), ((obj.rangeCenter.floatValue - lowestBid.floatValue) * pixelsPerAssetDeltaUnit) + depthChartBottomInset}];
                    [_drawablePaths addObject:askDepthLine];
                    NSBezierPath* askLineCircle = [NSBezierPath bezierPathWithOvalInRect:(NSRect){askDepthLine.currentPoint.x - 2, askDepthLine.currentPoint.y - 2, 4, 4}];
                    [_drawablePaths addObject:askLineCircle];
                    [self.depthAskCircleBezierPathsArray addObject:askLineCircle];
                }
            }];
            break;
        }
            
        case TTDepthViewChartingProcedureAllOrders:
        {
            [self.bids enumerateObjectsUsingBlock:^(TTDepthOrder* obj, NSUInteger idx, BOOL *stop) {
                NSBezierPath* bidDepthLine = [NSBezierPath bezierPath];
                [bidDepthLine setLineWidth:1.0f];
                [bidDepthLine moveToPoint:(NSPoint){CGRectGetMidX(graphRect), ((obj.price.floatValue - lowestBid.floatValue) * pixelsPerAssetDeltaUnit) + depthChartBottomInset}];
                [bidDepthLine lineToPoint:(NSPoint){CGRectGetMidX(graphRect) - ((obj.amount.floatValue / largestBidOrderSize.floatValue) * (CGRectGetWidth(graphRect) / 2)), ((obj.price.floatValue - lowestBid.floatValue) * pixelsPerAssetDeltaUnit) + depthChartBottomInset}];
                [_drawablePaths addObject:bidDepthLine];
                NSBezierPath* bidLineCircle = [NSBezierPath bezierPathWithOvalInRect:(NSRect){bidDepthLine.currentPoint.x - 2, bidDepthLine.currentPoint.y - 2, 4, 4}];
                [_drawablePaths addObject:bidLineCircle];
                [self.depthBidCircleBezierPathsArray addObject:bidLineCircle];
            }];
            
            [self.asks enumerateObjectsUsingBlock:^(TTDepthOrder* obj, NSUInteger idx, BOOL *stop) {
                NSBezierPath* askDepthLine = [NSBezierPath bezierPath];
                [askDepthLine setLineWidth:1.f];
                [askDepthLine moveToPoint:(NSPoint){CGRectGetMidX(graphRect), ((obj.price.floatValue - lowestBid.floatValue) * pixelsPerAssetDeltaUnit) + depthChartBottomInset}];
                [askDepthLine lineToPoint:(NSPoint){CGRectGetMidX(graphRect) + ((obj.amount.floatValue / largestAskOrderSize.floatValue) * (CGRectGetWidth(graphRect) / 2)), ((obj.price.floatValue - lowestBid.floatValue) * pixelsPerAssetDeltaUnit) + depthChartBottomInset}];
                [_drawablePaths addObject:askDepthLine];
                NSBezierPath* askLineCircle = [NSBezierPath bezierPathWithOvalInRect:(NSRect){askDepthLine.currentPoint.x - 2, askDepthLine.currentPoint.y - 2, 4, 4}];
                [_drawablePaths addObject:askLineCircle];
                [self.depthAskCircleBezierPathsArray addObject:askLineCircle];
            }];
            break;
        }
            
        default:
            break;
    }
    
    [self setLineDataIsDirty:NO];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [containingRectPath stroke];
    
    CGFloat pixelsPerAssetDeltaUnit = CGRectGetHeight(graphRectPtr) / assetDelta.floatValue;
    
    [stringForPriceNumber(lowestBid) drawAtPoint:(NSPoint){0, depthChartBottomInset - 5} withAttributes:attributeDictionaryForGraphYLabel()];
    [stringForPriceNumber(highestAsk) drawAtPoint:(NSPoint){CGRectGetMaxX(graphRectPtr), CGRectGetMaxY(graphRectPtr) - 5} withAttributes:attributeDictionaryForGraphYLabel()];
    
    NSSize renderedHighestBidTextSize = [stringForPriceNumber(highestBid) sizeWithAttributes:attributeDictionaryForGraphYLabel()];
    NSSize renderedLowestAskTextSize = [stringForPriceNumber(lowestAsk) sizeWithAttributes:attributeDictionaryForGraphYLabel()];
    [stringForPriceNumber(highestBid) drawAtPoint:(NSPoint){0, (pixelsPerAssetDeltaUnit * (highestBid.floatValue - lowestBid.floatValue)) + depthChartBottomInset - (renderedHighestBidTextSize.height / 2)} withAttributes:attributeDictionaryForGraphYLabel()];
    [stringForPriceNumber(lowestAsk) drawAtPoint:(NSPoint){CGRectGetMaxX(graphRectPtr), (pixelsPerAssetDeltaUnit * (lowestAsk.floatValue - lowestBid.floatValue)) + depthChartBottomInset - (renderedLowestAskTextSize.height / 2)} withAttributes:attributeDictionaryForGraphYLabel()];
    
    if (self.hasSeededDepthData)
    {
        if (self.lineDataIsDirty)
        {
            [self processData];
            [self drawDepthTableInRect:dirtyRect graphRect:graphRectPtr pixelsPerAssetUnitDelta:pixelsPerAssetDeltaUnit];
        }
        [self.drawablePaths enumerateObjectsUsingBlock:^(NSBezierPath* obj, NSUInteger idx, BOOL *stop) {
            if (idx == leadingElementsToDrawBlack)
                [[NSColor colorWithHexString:@"67C8FF"]set];
            [obj stroke];
        }];
        [[NSColor grayColor]set];
        if (self.xAxisCrosshair && self.yAxisCrosshair)
        {
            [self.labelingDelegate shouldEndShowingInfoPane];
            [self.xAxisCrosshair stroke];
            [self.yAxisCrosshair stroke];
            [self.labelingDelegate updatePriceString:RUStringWithFormat(@"%@%.3f",currencySymbolStringFromCurrency(self.currency), ((self.xAxisCrosshair.currentPoint.y - depthChartBottomInset) / pixelsPerAssetDeltaUnit) + lowestBid.floatValue)];
        }
        else
            [self.labelingDelegate shouldEndShowingPrice];
    }
    
}




@end
