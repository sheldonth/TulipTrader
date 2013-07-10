//
//  TTAxisMarkView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/10/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTAxisMarkView.h"

@interface TTAxisMarkView()

// Tick mark hangs in the upper right hand corner of the square, the text is drawn at an angle
@property(nonatomic, retain)NSBezierPath* tickMark;

@end

@implementation TTAxisMarkView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setLabel:[[JNWLabel alloc]initWithFrame:(NSRect){0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)}]];
        [self addSubview:_label];
    
        [self setTickMark:[NSBezierPath bezierPath]];
        [_tickMark moveToPoint:(NSPoint){CGRectGetMaxX(frame), CGRectGetMaxY(frame)}];
        [_tickMark lineToPoint:(NSPoint){CGRectGetMaxX(frame), CGRectGetMaxY(frame) - _tickLength}];
        [_tickMark setLineWidth:4.f];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [_tickMark stroke];
}

@end
