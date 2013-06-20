//
//  TTOrderBookWindow.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/19/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTOrderBookWindow.h"

@interface TTOrderBookWindow()

@end

@implementation TTOrderBookWindow

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self)
    {
        [self setMasterViewController:[[TTMasterViewController alloc]initWithFrame:(NSRect){0,0,contentRect.size.width, contentRect.size.height}]];
        [self.contentView addSubview:_masterViewController];
    }
    return self;
}

@end
