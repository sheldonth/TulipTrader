//
//  TTOrderBookWindow.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/10/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTOrderBookWindow.h"
#import "TTCurrency.h"
#import "TTOrderBookView.h"
#import "TTTabBarView.h"

#define kTTTabBarHeight 30.f

@interface TTOrderBookWindow()

@property(nonatomic, retain)NSMutableArray* tabs;
@property(nonatomic, retain)TTTabBarView* tabBarView;

@end


@implementation TTOrderBookWindow

-(void)didSelectViewAtIndex:(NSInteger)index
{
    [self.tabs enumerateObjectsUsingBlock:^(NSView* obj, NSUInteger idx, BOOL *stop) {
        if ([[self.contentView subviews]containsObject:obj])
            [obj removeFromSuperview];
    }];
    [self.contentView addSubview:[self.tabs objectAtIndex:index]];
}

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag currencies:(NSArray *)currencies
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    
    if (self)
    {
        [self setTabs:[NSMutableArray array]];
        
        [self setTabBarView:[[TTTabBarView alloc]initWithFrame:(NSRect){0, CGRectGetHeight(contentRect) - kTTTabBarHeight, CGRectGetWidth(contentRect), kTTTabBarHeight}]];
        
        [_tabBarView setAutoresizingMask:NSViewWidthSizable];
        
        [_tabBarView setDelegate:self];
        
        [self.contentView addSubview:_tabBarView];
        
        [currencies enumerateObjectsUsingBlock:^(NSString* currencyStr, NSUInteger idx, BOOL *stop) {
            
            TTOrderBookView* orderBookView = [[TTOrderBookView alloc]initWithFrame:(NSRect){0, 0 , CGRectGetWidth(contentRect), CGRectGetHeight(contentRect) - kTTTabBarHeight} currency:currencyFromString(currencyStr)];
            
            [orderBookView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
            
            [self.tabs addObject:orderBookView];
            
            [self.tabBarView addOrderBookView:orderBookView];
        }];
    }
    
    return self;
}



@end
