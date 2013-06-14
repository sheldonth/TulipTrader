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
}
@property(nonatomic, retain)NSArray* bids;
@property(nonatomic, retain)NSArray* asks;
@property(nonatomic, retain)NSDictionary* maxMinTicks;

@end

@implementation TTDepthStackView

#define depthChartBottomInset 0.f
#define depthChartTopInset 20.f
#define depthChartLeftSideInsets 17.f
#define depthChartRightSideInsets 17.f
#define intervalsAcrossSpread 20
#define midPointInterval 10

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
        [self setNeedsDisplay:YES];
    } withFailBlock:^(NSError *e) {
        
    }];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setHasSeededDepthData:NO];
    }
    
    return self;
}

-(void)setCurrency:(TTGoxCurrency)currency
{
    [self loadDepthForCurrency:currency];
    [self willChangeValueForKey:@"currency"];
    _currency = currency;
    [self didChangeValueForKey:@"currency"];
}

-(void)drawDepthTableInRect:(NSRect)dirtyRect
{
    NSRect graphRect = (NSRect)(NSRect){depthChartLeftSideInsets, depthChartBottomInset, CGRectGetWidth(dirtyRect) - (depthChartLeftSideInsets + depthChartRightSideInsets), CGRectGetHeight(dirtyRect) - (depthChartBottomInset + depthChartTopInset)};
    
    NSBezierPath* containingRect = [NSBezierPath bezierPathWithRect:graphRect];
    [containingRect stroke];

    CGFloat pixelsPerAssetDeltaUnit = CGRectGetHeight(graphRect) / assetDelta.floatValue;
    
    int yBaseOffset = 5;
    
    [stringForPriceNumber(lowestBid) drawAtPoint:(NSPoint){0, yBaseOffset} withAttributes:attributeDictionaryForGraphYLabel()];
    [stringForPriceNumber(highestAsk) drawAtPoint:(NSPoint){CGRectGetMaxX(graphRect), CGRectGetMaxY(graphRect) - 5} withAttributes:attributeDictionaryForGraphYLabel()];
    
    [stringForPriceNumber(highestBid) drawAtPoint:(NSPoint){0, pixelsPerAssetDeltaUnit * (highestBid.floatValue - lowestBid.floatValue)} withAttributes:attributeDictionaryForGraphYLabel()];
    [stringForPriceNumber(lowestAsk) drawAtPoint:(NSPoint){CGRectGetMaxX(graphRect), pixelsPerAssetDeltaUnit * (lowestAsk.floatValue - lowestBid.floatValue)} withAttributes:attributeDictionaryForGraphYLabel()];
    
    [[NSColor colorWithHexString:@"67C8FF"]set];
    
    [self.bids enumerateObjectsUsingBlock:^(TTDepthOrder* obj, NSUInteger idx, BOOL *stop) {
        NSBezierPath* p = [NSBezierPath bezierPath];
        [p setLineWidth:1.0f];
        [p moveToPoint:(NSPoint){CGRectGetMidX(graphRect), ((obj.price.floatValue - lowestBid.floatValue) * pixelsPerAssetDeltaUnit) + depthChartBottomInset}];
        [p lineToPoint:(NSPoint){CGRectGetMidX(graphRect) - ((obj.amount.floatValue / largestBidOrderSize.floatValue) * (CGRectGetWidth(graphRect) / 2)), ((obj.price.floatValue - lowestBid.floatValue) * pixelsPerAssetDeltaUnit) + depthChartBottomInset}];
        [p stroke];
        NSBezierPath* circ = [NSBezierPath bezierPathWithOvalInRect:(NSRect){p.currentPoint.x - 2, p.currentPoint.y - 2, 4, 4}];
        [circ stroke];
    }];
    
    [self.asks enumerateObjectsUsingBlock:^(TTDepthOrder* obj, NSUInteger idx, BOOL *stop) {
        NSBezierPath* p = [NSBezierPath bezierPath];
        [p setLineWidth:1.f];
        [p moveToPoint:(NSPoint){CGRectGetMidX(graphRect), ((obj.price.floatValue - lowestBid.floatValue) * pixelsPerAssetDeltaUnit) + depthChartBottomInset}];
        [p lineToPoint:(NSPoint){CGRectGetMidX(graphRect) + ((obj.amount.floatValue / largestAskOrderSize.floatValue) * (CGRectGetWidth(graphRect) / 2)), ((obj.price.floatValue - lowestBid.floatValue) * pixelsPerAssetDeltaUnit) + depthChartBottomInset}];
        [p stroke];
        NSBezierPath* circ = [NSBezierPath bezierPathWithOvalInRect:(NSRect){p.currentPoint.x - 2, p.currentPoint.y - 2, 4, 4}];
        [circ stroke];
    }];
        
    NSBezierPath* rectPath = [NSBezierPath bezierPath];
    [rectPath moveToPoint:(NSPoint){CGRectGetMidX(dirtyRect), CGRectGetHeight(dirtyRect) - depthChartTopInset}];
    [rectPath lineToPoint:(NSPoint){CGRectGetMidX(dirtyRect), depthChartBottomInset}];
    [rectPath stroke];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (self.hasSeededDepthData)
        [self drawDepthTableInRect:dirtyRect];
}




@end