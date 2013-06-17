//
//  TTDepthGridView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/11/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTDepthGridView.h"
#import "TTGoxHTTPController.h"
#import "RUConstants.h"
#import "TTGoxCurrencyController.h"
#import "TTDepthStackView.h"
#import "TTGoxCurrency.h"

@interface TTDepthGridView()

@property(nonatomic, retain)NSMutableArray* depthScrollViewsArray;
@property(nonatomic, retain)NSMutableArray* depthStackViewsArray;

@property(nonatomic)NSRect depthStackViewBaseRect;

@end

#define graphsTopOffset 24.f
#define graphsBottomOffset 15.f

@implementation TTDepthGridView

-(void)setDepthStackView:(TTDepthStackView*)stackView toZoom:(NSInteger)zoomLevel
{
    [stackView setZoomLevel:zoomLevel];
    [stackView setFrame:(NSRect){self.depthStackViewBaseRect.origin.x, self.depthStackViewBaseRect.origin.y, self.depthStackViewBaseRect.size.width, self.depthStackViewBaseRect.size.height * zoomLevel}];
    [stackView setLineDataIsDirty:YES];
    [stackView setNeedsDisplay:YES];
}

-(void)stepperDidChange:(NSStepper*)sender
{
    if ([sender class] != [NSStepper class])
        [NSException raise:@"Bad NSStepper Class" format:@""];
    NSInteger e = [sender integerValue];
    [self setDepthStackView:[self.depthStackViewsArray objectAtIndex:0] toZoom:e];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setDepthScrollViewsArray:[NSMutableArray array]];
        [self setDepthStackViewsArray:[NSMutableArray array]];

        NSArray* __activeCurrencies = [TTGoxCurrencyController activeCurrencys];
        CGFloat stackWidth = floorf(CGRectGetWidth(frame) / __activeCurrencies.count);
        [__activeCurrencies enumerateObjectsUsingBlock:^(NSString* currencyStr, NSUInteger idx, BOOL *stop) {
//            if (currencyFromString(currencyStr) == TTGoxCurrencyUSD)
//            {
                NSScrollView* scrollView = [[NSScrollView alloc]initWithFrame:(NSRect){0 + (stackWidth * idx), graphsBottomOffset, stackWidth, CGRectGetHeight(frame) - (graphsTopOffset + graphsBottomOffset)}];
                [scrollView setHasVerticalScroller:YES];
                [scrollView setHasHorizontalScroller:YES];
                [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
                TTDepthStackView* depthStackView = [[TTDepthStackView alloc]initWithFrame:scrollView.frame];
                [depthStackView setZoomLevel:1];
                self.depthStackViewBaseRect = depthStackView.frame;
                [scrollView setDocumentView:depthStackView];
                [scrollView setDrawsBackground:NO];
                [depthStackView setCurrency:currencyFromString(currencyStr)];
                [self.depthStackViewsArray addObject:depthStackView];
                [self.depthScrollViewsArray addObject:scrollView];
                [self addSubview:scrollView];
                
                NSStepper* stepper = [[NSStepper alloc]initWithFrame:(NSRect){CGRectGetMidX(scrollView.frame), CGRectGetMaxY(scrollView.frame) + 1, 30, 22}];
                [stepper setTarget:self];
                [stepper setTag:idx];
                [stepper setAction:@selector(stepperDidChange:)];
                [stepper setMinValue:1];
                [stepper setMaxValue:4];
                [stepper setIncrement:1];
                [stepper setIntegerValue:1];
                [self addSubview:stepper];
//             }
        }];
    }
    return self;
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//    [[NSColor orangeColor] setFill];
//    NSRectFill(dirtyRect);
//}

@end
