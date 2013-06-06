//
//  TTGraphsWindow.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/8/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTGraphsWindow.h"
#import "TTGraphView.h"

@interface TTGraphsWindow()

@property(nonatomic, retain)TTGraphView* graphViewTop;
@property(nonatomic, retain)TTGraphView* graphViewLower;
@property(nonatomic)CGSize graphSize;

@end

#define kTTGraphsWindowNumberOfGraphs 2

@implementation TTGraphsWindow

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self)
    {
        [self setGraphSize:(CGSize){CGRectGetWidth(contentRect), floorf(CGRectGetHeight(contentRect) / kTTGraphsWindowNumberOfGraphs)}];
        
        [self setGraphViewLower:[[TTGraphView alloc]initWithFrame:(NSRect){0,0,_graphSize}]];
        [self.contentView addSubview:_graphViewLower];
        
        [self setGraphViewTop:[[TTGraphView alloc]initWithFrame:(NSRect){0, _graphSize.height, _graphSize}]];
        [self.contentView addSubview:_graphViewTop];
    }
    return self;
}

#pragma mark - C methods

@end
