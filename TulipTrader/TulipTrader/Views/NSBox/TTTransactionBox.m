//
//  TTTransactionBox.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/6/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTTransactionBox.h"

@implementation TTTransactionBox

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBorderWidth:2.f];
        [self setBorderColor:[NSColor blackColor]];
        [self setTitle:@"Transaction"];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

@end
