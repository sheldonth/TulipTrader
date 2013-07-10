//
//  TTAxisView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/9/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTAxisView.h"

@interface TTAxisView()

@property(nonatomic, retain)NSMutableArray* labels;

@end

@implementation TTAxisView

- (id)initWithFrame:(NSRect)frame contentOriginOffset:(CGFloat)contentOriginOffset maxPlottedValue:(NSInteger)maxPlotValue interval:(NSInteger)interval
{
    self = [super initWithFrame:frame];
    if (self) {
        _labels = [NSMutableArray array];
    
        NSInteger plots = (maxPlotValue / interval) * 2; // doubled because it starts from zero in the middle and goes both ways
        
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor redColor]set];
    NSRectFill(dirtyRect);
}

@end
