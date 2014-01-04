//
//  TTRulerView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/9/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTRulerView.h"
#import "RUConstants.h"

@implementation TTRulerView

-(id)initWithScrollView:(NSScrollView *)scrollView orientation:(NSRulerOrientation)orientation
{
    self = [super initWithScrollView:scrollView orientation:orientation];
    if (self)
    {
        
//        [self setOriginOffset:280.f];
//        [self setReservedThicknessForAccessoryView:1.f];
//        [self setMarkers:@[@1, @2, @3]];
        
    }
    return self;
}
- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

@end
