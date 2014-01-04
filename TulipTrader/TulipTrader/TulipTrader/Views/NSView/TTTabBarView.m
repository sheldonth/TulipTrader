//
//  TTTabBarView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/10/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTTabBarView.h"

#define kTTTabBarBtnHeight 20.f
#define kTTTabBarBtnWidth 120.f
#define kTTTabBarBtnSpace 50.f

@interface TTTabBarView()

@property(nonatomic, retain)NSMutableArray* tabBarButtons;

@end

@implementation TTTabBarView

-(void)didPressTab:(NSButton*)sender
{
//    [sender set]
    NSInteger idx = [self.tabBarButtons indexOfObject:sender];
    if (idx == NSNotFound)
    {NSException* e = [[NSException alloc]initWithName:NSInternalInconsistencyException reason:@"btn not found in array" userInfo:nil]; @throw e;}
    if (self.delegate)
        [self.delegate didSelectViewAtIndex:idx];
}

-(void)addOrderBookView:(TTOrderBookView *)orderBookView
{
    NSButton* btn = [[NSButton alloc]initWithFrame:(NSRect){(kTTTabBarBtnSpace / 2) + (self.tabBarButtons.count * (kTTTabBarBtnSpace + kTTTabBarBtnWidth)), 0, kTTTabBarBtnWidth, kTTTabBarBtnHeight}];
    [btn setTarget:self];
    [btn setAction:@selector(didPressTab:)];
    [btn setTitle:orderBookView.orderBook.title];
    [btn setButtonType:NSPushOnPushOffButton];
    [_tabBarButtons addObject:btn];
    [self addSubview:btn];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTabBarButtons:[NSMutableArray array]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
