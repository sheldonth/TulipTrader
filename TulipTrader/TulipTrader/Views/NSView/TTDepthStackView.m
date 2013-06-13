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

@interface TTDepthStackView ()
{
    
}
@property(nonatomic, retain)NSArray* bids;
@property(nonatomic, retain)NSArray* asks;
@property(nonatomic, retain)NSDictionary* maxMinTicks;

@end

@implementation TTDepthStackView

#define depthChartBottomInset 20.f
#define depthChartSideInsets 10.f
#define intervalsAcrossSpread 8

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
        [self setMaxMinTicks:maxMinTicks];
        [self setHasSeededDepthData:YES];
        [self setNeedsDisplay:YES];
    } withFailBlock:^(NSError *e) {
        RUDLog(@"!");
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
    NSBezierPath* containingRect = [NSBezierPath bezierPathWithRect:(NSRect){depthChartSideInsets, depthChartBottomInset, CGRectGetWidth(dirtyRect) - (2 * depthChartSideInsets), CGRectGetHeight(dirtyRect) - depthChartBottomInset}];
    [containingRect stroke];
    
    NSBezierPath* rectPath = [NSBezierPath bezierPath];
    [rectPath moveToPoint:(NSPoint){CGRectGetMidX(dirtyRect), CGRectGetHeight(dirtyRect)}];
    [rectPath lineToPoint:(NSPoint){CGRectGetMidX(dirtyRect), depthChartBottomInset}];
    [rectPath stroke];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (self.hasSeededDepthData)
        [self drawDepthTableInRect:dirtyRect];
}

/*
 
 CGContextRef context = [[NSGraphicsContext currentContext]graphicsPort];
 CGContextMoveToPoint(context, 0, 0);
 CGContextClearRect(context, dirtyRect);
 [[NSColor whiteColor] setFill];
 NSRectFill(dirtyRect);
 drawLine(context, 1.f, [NSColor blackColor].CGColor, (CGPoint){0, CGRectGetHeight(dirtyRect)}, (CGPoint){CGRectGetWidth(dirtyRect), CGRectGetHeight(dirtyRect)});
 */



@end
