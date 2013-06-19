//
//  TTDepthInfoPopoverView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/18/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTDepthInfoPopoverView.h"

@implementation TTDepthInfoPopoverView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (self.backgroundColor)
    {
        [self.backgroundColor setFill];
        NSRectFill(dirtyRect);
    }
}

@end
