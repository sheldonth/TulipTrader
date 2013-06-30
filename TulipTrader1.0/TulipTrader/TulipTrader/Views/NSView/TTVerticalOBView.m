//
//  TTVerticalOBView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/13/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTVerticalOBView.h"
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
        [self setDepth:@0];
        [self setOrders:@0];
        [self setRangeCenter:@0];
    }
    return self;
}

@end

@interface TTVerticalOBView ()
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
    NSRect headerRectPtr;
    CGFloat pixelsPerAssetDeltaUnit;
}

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
@property(nonatomic, retain)NSMutableArray* labelNumbersArray;

-(NSInteger)depthSamplesForZoom;

@end

@implementation TTVerticalOBView

#define depthChartBottomInset 35.f
#define depthChartTopInset 35.f
#define depthChartLeftSideInsets 35.f
#define depthChartRightSideInsets 35.f

#define leadingElementsToDrawBlack 3

#define numberOfDepthSamples 50

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
    
    NSArray* askDepthCircles = [self.depthAskCircleBezierPathsArray copy];
    NSArray* bidDepthCircles = [self.depthBidCircleBezierPathsArray copy];
    switch (self.chartingProcedure)
    {
        case TTDepthViewChartingProcedureSampling:
        {
            NSArray* a = [askDepthCircles copy];
            NSArray* b = [bidDepthCircles copy];
            [a enumerateObjectsUsingBlock:^(NSBezierPath* obj, NSUInteger idx, BOOL *stop) {
                if ([obj containsPoint:convertedPt])
                    [crossHairHits addObject:obj];
            }];
            [b enumerateObjectsUsingBlock:^(NSBezierPath* obj, NSUInteger idx, BOOL *stop) {
                if ([obj containsPoint:convertedPt])
                    [crossHairHits addObject:obj];
            }];
            break;
        }
            
        case TTDepthViewChartingProcedureAllOrders:
        {
            NSArray* a = [askDepthCircles copy];
            NSArray* b = [bidDepthCircles copy];
            [a enumerateObjectsUsingBlock:^(NSBezierPath* obj, NSUInteger idx, BOOL *stop) {
                if ([obj containsPoint:convertedPt])
                    [crossHairHits addObject:obj];
            }];
            [b enumerateObjectsUsingBlock:^(NSBezierPath* obj, NSUInteger idx, BOOL *stop) {
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

-(void)setBids:(NSArray *)bids
{
    [self willChangeValueForKey:@"bids"];
    _bids = bids;
    [self setNeedsCalibration:YES];
    [self didChangeValueForKey:@"bids"];
}

-(void)setAsks:(NSArray *)asks
{
    [self willChangeValueForKey:@"asks"];
    _asks = asks;
    [self setNeedsCalibration:YES];
    [self didChangeValueForKey:@"asks"];
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
    return priceNumber.stringValue;
//    if (priceNumber.floatValue < 100.f)
//        return RUStringWithFormat(@"%.1f", priceNumber.floatValue);
//    else
//        return RUStringWithFormat(@"%.0f", priceNumber.floatValue);
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

-(void)processData
{
    [self setBidsPositionValues:[NSMutableArray array]];
    [self setAsksPositionValues:[NSMutableArray array]];
    
    highestBid = [[self.allBids lastObject]price];
    lowestAsk = [[self.allAsks objectAtIndex:0]price];
    
    NSNumber* bidCutoff = @(highestBid.floatValue * (1 - self.bidInclusionDifferential.floatValue));
    NSNumber* askCutoff = @(lowestAsk.floatValue * (1 + self.askInclusionDifferential.floatValue));
    
    [self setBids:[self.allBids filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"price > %@", bidCutoff]]];
    [self setAsks:[self.allAsks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"price < %@", askCutoff]]];
    
    lowestBid = [[self.bids objectAtIndex:0]price];
    
    highestAsk = [[self.asks lastObject]price];
    
    assetDelta = @(highestAsk.floatValue - lowestBid.floatValue);
    
    pixelsPerAssetDeltaUnit = CGRectGetHeight(graphRectPtr) / assetDelta.floatValue;
    
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
        if (bidsInRange.count)
        {
            TTDepthPositionValue* depthPositionValue = [[TTDepthPositionValue alloc]init];
            [depthPositionValue setRangeCenter:@((highEnd.floatValue + lowEnd.floatValue) / 2)];
            [bidsInRange enumerateObjectsUsingBlock:^(TTDepthOrder* obj, NSUInteger idx, BOOL *stop) {
                [depthPositionValue setDepth:@(depthPositionValue.depth.floatValue + obj.amount.floatValue)];
                [depthPositionValue setOrders:@(depthPositionValue.orders.floatValue + 1)];
            }];
            [self.bidsPositionValues addObject:depthPositionValue];
        }
    };
    
    TTDepthPositionValue* maxBidDepth = [[self.bidsPositionValues sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"depth" ascending:NO]]]objectAtIndex:0];
    maxBidPositionDepth = [maxBidDepth depth];
    
    for (int i = 0; i < self.depthSamplesForZoom; i++) {
        NSNumber* lowEnd = @(lowestAsk.floatValue + (askPositionsDelta.floatValue * i));
        NSNumber* highEnd = @(lowestAsk.floatValue + (askPositionsDelta.floatValue * (i + 1)));
        NSPredicate* pred = [NSPredicate predicateWithFormat:@"price BETWEEN %@", @[lowEnd, highEnd]];
        NSArray* asksInRange = [self.asks filteredArrayUsingPredicate:pred];
        if (asksInRange.count)
        {
            TTDepthPositionValue* depthPositionValue = [[TTDepthPositionValue alloc]init];
            [depthPositionValue setRangeCenter:@((highEnd.floatValue + lowEnd.floatValue) / 2)];
            [asksInRange enumerateObjectsUsingBlock:^(TTDepthOrder* obj, NSUInteger idx, BOOL *stop) {
                [depthPositionValue setDepth:@(depthPositionValue.depth.floatValue + obj.amount.floatValue)];
                [depthPositionValue setOrders:@(depthPositionValue.orders.floatValue + 1)];
            }];
            [self.asksPositionValues addObject:depthPositionValue];
        }
    }
    TTDepthPositionValue* maxAskDepth = [[self.asksPositionValues sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"depth" ascending:NO]]]objectAtIndex:0];
    maxAskPositionDepth = [maxAskDepth depth];
    
    if (maxAskPositionDepth.floatValue > maxBidPositionDepth.floatValue)
        maxGeneralPositionDepth = maxAskPositionDepth;
    else
        maxGeneralPositionDepth = maxBidPositionDepth;
    
    [self drawDepthTableInRect:self.frame graphRect:graphRectPtr];
    
    [self setNeedsCalibration:NO];
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setZoomLevel:1];
        [self setBidInclusionDifferential:@.10];
        [self setAskInclusionDifferential:@.10];
        [self setChartingProcedure:(TTDepthViewChartingProcedureSampling)];
        graphRectPtr = (NSRect){depthChartLeftSideInsets, depthChartBottomInset, CGRectGetWidth(frame) - (depthChartLeftSideInsets + depthChartRightSideInsets), CGRectGetHeight(frame) - (depthChartBottomInset + depthChartTopInset)};
        
        headerRectPtr = (NSRect){depthChartLeftSideInsets, CGRectGetMaxY(graphRectPtr), CGRectGetWidth(graphRectPtr), 15};
        
        [self setTrackingArea:[[NSTrackingArea alloc]initWithRect:graphRectPtr options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved+NSTrackingActiveInKeyWindow) owner:self userInfo:nil]];
        [self addTrackingArea:_trackingArea];
    }
    
    return self;
}

-(void)drawDepthTableInRect:(NSRect)dirtyRect graphRect:(NSRect)graphRect
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
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSBezierPath bezierPathWithRect:graphRectPtr]stroke];
    [[NSBezierPath bezierPathWithRect:headerRectPtr]stroke];
    
    [stringForPriceNumber(lowestBid) drawAtPoint:(NSPoint){0, depthChartBottomInset - 5} withAttributes:attributeDictionaryForGraphYLabel()];
    
    [stringForPriceNumber(highestAsk) drawAtPoint:(NSPoint){CGRectGetMaxX(graphRectPtr), CGRectGetMaxY(graphRectPtr) - 5} withAttributes:attributeDictionaryForGraphYLabel()];
    
    NSSize renderedHighestBidTextSize = [stringForPriceNumber(highestBid) sizeWithAttributes:attributeDictionaryForGraphYLabel()];
    NSSize renderedLowestAskTextSize = [stringForPriceNumber(lowestAsk) sizeWithAttributes:attributeDictionaryForGraphYLabel()];
    
    [stringForPriceNumber(highestBid) drawAtPoint:(NSPoint){0, (pixelsPerAssetDeltaUnit * (highestBid.floatValue - lowestBid.floatValue)) + depthChartBottomInset - (renderedHighestBidTextSize.height / 2)} withAttributes:attributeDictionaryForGraphYLabel()];
    [stringForPriceNumber(lowestAsk) drawAtPoint:(NSPoint){CGRectGetMaxX(graphRectPtr), (pixelsPerAssetDeltaUnit * (lowestAsk.floatValue - lowestBid.floatValue)) + depthChartBottomInset - (renderedLowestAskTextSize.height / 2)} withAttributes:attributeDictionaryForGraphYLabel()];

    [self.drawablePaths enumerateObjectsUsingBlock:^(NSBezierPath* obj, NSUInteger idx, BOOL *stop) {
        if (idx == leadingElementsToDrawBlack)
            [[NSColor colorWithHexString:@"67C8FF"]set];
        [obj stroke];
    }];
    [[NSColor grayColor]set];
    if (self.xAxisCrosshair && self.yAxisCrosshair)
    {
        [self.xAxisCrosshair stroke];
        [self.yAxisCrosshair stroke];
    }
}


@end
