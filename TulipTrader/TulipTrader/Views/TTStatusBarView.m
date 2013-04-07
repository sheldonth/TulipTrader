//
//  TTStatusBarView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/5/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTStatusBarView.h"

@implementation TTStatusBarView

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
    [[NSColor orangeColor] setFill];
    NSRectFill(dirtyRect);
}

@end
