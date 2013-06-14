//
//  TTDepthStackView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/13/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTDepthStackView.h"
#import "TTGoxHTTPController.h"
#import "RUConstants.h"
#import "TTDepthOrder.h"
#import "NSColor+Hex.h"

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
    
    NSRect graphRectPtr;
    NSBezierPath* containingRectPath;
}
@property(nonatomic, retain)NSArray* bids;
@property(nonatomic, retain)NSArray* asks;
@property(nonatomic, retain)NSDictionary* maxMinTicks;
@property(nonatomic, retain)NSButton* zoomIn;
@property(nonatomic, retain)NSButton* zoomOut;
@property(nonatomic, retain)NSMutableArray* drawablePaths;

@end

@implementation TTDepthStackView

#define depthChartBottomInset 20.f
#define depthChartTopInset 5.f
#define depthChartLeftSideInsets 17.f
#define depthChartRightSideInsets 17.f
#define intervalsAcrossSpread 20
#define midPointInterval 10
#define leadingElementsToDrawBlack 3

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
    [self loadDepthForCurrency:self.currency];
}

-(void)loadDepthForCurrency:(TTGoxCurrency)curr
{
    [[TTGoxHTTPController sharedInstance]getDepthForCurrency:curr withCompletion:^(NSArray *bids, NSArray *asks, NSDictionary *maxMinTicks) {
        [self setBids:bids];
        [self setAsks:asks];
        lowestBid = [[self.bids objectAtIndex:0]price];
        highestBid = [[self.bids lastObject]price];
        lowestAsk = [[self.asks objectAtIndex:0]price];
        highestAsk = [[self.asks lastObject]price];
        assetDelta = @(highestAsk.floatValue - lowestBid.floatValue);
        assetMidpoint = @((highestAsk.floatValue + lowestBid.floatValue) / 2);
        largestBidOrderSize = [[[self.bids sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"amount" ascending:NO]]]objectAtIndex:0] amount];
        largestAskOrderSize = [[[self.asks sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"amount" ascending:NO]]]objectAtIndex:0] amount];
        [self setMaxMinTicks:maxMinTicks];
        [self setHasSeededDepthData:YES];
        [self setLineDataIsDirty:YES];
        [self setNeedsDisplay:YES];
    } withFailBlock:^(NSError *e) {
        [NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(reload) userInfo:nil repeats:NO];
    }];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setHasSeededDepthData:NO];
        graphRectPtr = (NSRect){depthChartLeftSideInsets, depthChartBottomInset, CGRectGetWidth(frame) - (depthChartLeftSideInsets + depthChartRightSideInsets), CGRectGetHeight(frame) - (depthChartBottomInset + depthChartTopInset)};
        containingRectPath = [NSBezierPath bezierPathWithRect:graphRectPtr];
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
    [self loadDepthForCurrency:currency];
    [self willChangeValueForKey:@"currency"];
    _currency = currency;
    [self didChangeValueForKey:@"currency"];
}

-(void)drawDepthTableInRect:(NSRect)dirtyRect graphRect:(NSRect)graphRect pixelsPerAssetUnitDelta:(CGFloat)pixelsPerAssetDeltaUnit
{
    [self setDrawablePaths:[NSMutableArray array]];

    CGFloat dashArray[2];
    dashArray[0] = 2;
    dashArray[1] = 2;
    
    NSBezierPath* bidLine = [NSBezierPath bezierPath];
    [bidLine setLineDash:dashArray count:2 phase:0];
    [bidLine moveToPoint:(NSPoint){CGRectGetMinX(graphRect), (pixelsPerAssetDeltaUnit * (highestBid.floatValue - lowestBid.floatValue)) + depthChartBottomInset}];
    [bidLine lineToPoint:(NSPoint){CGRectGetMidX(graphRect), (pixelsPerAssetDeltaUnit * (highestBid.floatValue - lowestBid.floatValue)) + depthChartBottomInset}];
    [_drawablePaths addObject:bidLine];
//    [bidLine stroke];
    
    NSBezierPath* askLine = [NSBezierPath bezierPath];
    [askLine setLineDash:dashArray count:2 phase:0];
    [askLine moveToPoint:(NSPoint){CGRectGetMaxX(graphRect), (pixelsPerAssetDeltaUnit * (lowestAsk.floatValue - lowestBid.floatValue)) + depthChartBottomInset}];
    [askLine lineToPoint:(NSPoint){CGRectGetMaxX(graphRect) - (CGRectGetWidth(graphRect) / 2), (pixelsPerAssetDeltaUnit * (lowestAsk.floatValue - lowestBid.floatValue)) + depthChartBottomInset}];
    [_drawablePaths addObject:askLine];
//    [askLine stroke];
    
    NSBezierPath* rectMidLine = [NSBezierPath bezierPath];
    [rectMidLine moveToPoint:(NSPoint){CGRectGetMidX(graphRect), CGRectGetHeight(graphRect) - depthChartTopInset}];
    [rectMidLine lineToPoint:(NSPoint){CGRectGetMidX(graphRect), depthChartBottomInset}];
    [_drawablePaths addObject:rectMidLine];
//    [rectMidLine stroke];
    
    [self.bids enumerateObjectsUsingBlock:^(TTDepthOrder* obj, NSUInteger idx, BOOL *stop) {
        NSBezierPath* bidDepthLine = [NSBezierPath bezierPath];
        [bidDepthLine setLineWidth:1.0f];
        [bidDepthLine moveToPoint:(NSPoint){CGRectGetMidX(graphRect), ((obj.price.floatValue - lowestBid.floatValue) * pixelsPerAssetDeltaUnit) + depthChartBottomInset}];
        [bidDepthLine lineToPoint:(NSPoint){CGRectGetMidX(graphRect) - ((obj.amount.floatValue / largestBidOrderSize.floatValue) * (CGRectGetWidth(graphRect) / 2)), ((obj.price.floatValue - lowestBid.floatValue) * pixelsPerAssetDeltaUnit) + depthChartBottomInset}];
        [_drawablePaths addObject:bidDepthLine];
//        [bidDepthLine stroke];
        NSBezierPath* bidLineCircle = [NSBezierPath bezierPathWithOvalInRect:(NSRect){bidDepthLine.currentPoint.x - 2, bidDepthLine.currentPoint.y - 2, 4, 4}];
        [_drawablePaths addObject:bidLineCircle];
//        [circ stroke];
    }];
    
    [self.asks enumerateObjectsUsingBlock:^(TTDepthOrder* obj, NSUInteger idx, BOOL *stop) {
        NSBezierPath* askDepthLine = [NSBezierPath bezierPath];
        [askDepthLine setLineWidth:1.f];
        [askDepthLine moveToPoint:(NSPoint){CGRectGetMidX(graphRect), ((obj.price.floatValue - lowestBid.floatValue) * pixelsPerAssetDeltaUnit) + depthChartBottomInset}];
        [askDepthLine lineToPoint:(NSPoint){CGRectGetMidX(graphRect) + ((obj.amount.floatValue / largestAskOrderSize.floatValue) * (CGRectGetWidth(graphRect) / 2)), ((obj.price.floatValue - lowestBid.floatValue) * pixelsPerAssetDeltaUnit) + depthChartBottomInset}];
        [_drawablePaths addObject:askDepthLine];
//        [askDepthLine stroke];
        NSBezierPath* askLineCircle = [NSBezierPath bezierPathWithOvalInRect:(NSRect){askDepthLine.currentPoint.x - 2, askDepthLine.currentPoint.y - 2, 4, 4}];
        [_drawablePaths addObject:askLineCircle];
//        [askLineCircle stroke];
    }];
    [self setLineDataIsDirty:NO];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [containingRectPath stroke];
    
    CGFloat pixelsPerAssetDeltaUnit = CGRectGetHeight(graphRectPtr) / assetDelta.floatValue;
    
    [stringForPriceNumber(lowestBid) drawAtPoint:(NSPoint){0, depthChartBottomInset - 5} withAttributes:attributeDictionaryForGraphYLabel()];
    [stringForPriceNumber(highestAsk) drawAtPoint:(NSPoint){CGRectGetMaxX(graphRectPtr), CGRectGetMaxY(graphRectPtr) - 5} withAttributes:attributeDictionaryForGraphYLabel()];
    
    [stringForPriceNumber(highestBid) drawAtPoint:(NSPoint){0, (pixelsPerAssetDeltaUnit * (highestBid.floatValue - lowestBid.floatValue)) + depthChartBottomInset} withAttributes:attributeDictionaryForGraphYLabel()];
    [stringForPriceNumber(lowestAsk) drawAtPoint:(NSPoint){CGRectGetMaxX(graphRectPtr), (pixelsPerAssetDeltaUnit * (lowestAsk.floatValue - lowestBid.floatValue)) + depthChartBottomInset} withAttributes:attributeDictionaryForGraphYLabel()];
    
    if (self.hasSeededDepthData)
    {
        if (self.lineDataIsDirty)
            [self drawDepthTableInRect:dirtyRect graphRect:graphRectPtr pixelsPerAssetUnitDelta:pixelsPerAssetDeltaUnit];
        [self.drawablePaths enumerateObjectsUsingBlock:^(NSBezierPath* obj, NSUInteger idx, BOOL *stop) {
            if (idx == leadingElementsToDrawBlack)
                [[NSColor colorWithHexString:@"67C8FF"]set];
            [obj stroke];
        }];
    }
    
}




@end
