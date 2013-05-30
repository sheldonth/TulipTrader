//
//  TTAccountBox.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/30/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTAccountBox.h"

@implementation TTAccountBox

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBorderWidth:2.f];
        [self setBorderColor:[NSColor blackColor]];
        [self setTitle:@"Accounts"];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

@end
