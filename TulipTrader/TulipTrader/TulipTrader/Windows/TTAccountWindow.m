//
//  TTAccountWindow.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/25/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTAccountWindow.h"
#import "FastResizeView.h"
#import "TTAccountView.h"

@interface TTAccountWindow()

@property(nonatomic, retain)FastResizeView* resizeView;
@property(nonatomic, retain)TTAccountView* accountView;

@end

@implementation TTAccountWindow

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self)
    {
        self.resizeView = [[FastResizeView alloc]initWithFrame:(NSRect){0, 0, contentRect.size.width, contentRect.size.height}];
        [self setContentView:self.resizeView];
        
        self.accountView = [[TTAccountView alloc]initWithFrame:(NSRect){0, 0, contentRect.size.width, contentRect.size.height}];
        [self.resizeView addSubview:self.accountView];
    }
    return self;
}

-(void)setOrderBook:(TTOrderBook *)orderBook
{
    [self willChangeValueForKey:@"orderBook"];
    [self.accountView setOrderbook:orderBook];
    _orderBook = orderBook;
    [self didChangeValueForKey:@"orderBook"];
}

@end
