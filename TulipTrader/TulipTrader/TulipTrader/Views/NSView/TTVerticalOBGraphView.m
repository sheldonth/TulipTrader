//
//  TTVerticalOBGraphView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/9/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTVerticalOBGraphView.h"
#import "TTVerticalPanningView.h"
#import "RUConstants.h"
#import "TTAxisView.h"

/*
 
 TTVerticalOBGraphView contains the set of labeling for each side, and an instance of TTVerticalPanView which has the larger graph pannable inside it.
 
 */

@interface TTVerticalOBGraphView()
@property(nonatomic, retain)TTVerticalPanningView* panningView;
@property(nonatomic)CGFloat edgeInsets;
@property(nonatomic)NSInteger maxYPlotValue;
@property(nonatomic, retain)TTAxisView* lowerHorizontalAxis;
@end

@implementation TTVerticalOBGraphView

-(void)updateForAskSide:(TTDepthUpdate *)depthUpdate
{
    
}

-(void)updateForBidSide:(TTDepthUpdate *)depthUpdate
{
    
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _edgeInsets = floorf(frame.size.width / 20);
        
        [self setPanningView:[[TTVerticalPanningView alloc]initWithFrame:(NSRect){_edgeInsets, _edgeInsets, CGRectGetWidth(frame) - (2 * _edgeInsets), CGRectGetHeight(frame) - (2 * _edgeInsets)}]];
        
        [self addSubview:_panningView];
        
        [self setLowerHorizontalAxis:[[TTAxisView alloc]initWithFrame:(NSRect){_edgeInsets, 0, _panningView.frame.size.width, _edgeInsets} contentOriginOffset:(_panningView.frame.size.width / 2) maxPlottedValue:400 interval:100]];
        
        [self addSubview:_lowerHorizontalAxis];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor blackColor]set];
    NSRectFill(dirtyRect);
}

@end
