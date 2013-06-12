//
//  TTMasterViewController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/6/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTMasterViewController.h"
#import "TTStatusBarView.h"
#import "RUConstants.h"
#import "TTFrameConstants.h"
#import "TTArbitrageStackView.h"
#import "TTGoxCurrencyController.h"
#import "TTAPIControlBoxView.h"
#import "TTAccountBox.h"

@interface TTMasterViewController ()

@property(nonatomic, retain)TTStatusBarView* statusBarView;
@property(nonatomic, retain)NSMutableArray* arbitrageStackViewsArray;
@property(nonatomic, retain)TTAPIControlBoxView* controlBoxView;
@property(nonatomic, retain)TTAccountBox* accountBox;

@property(nonatomic)NSRect centerBodyRect;
@property(nonatomic)CGFloat centerBodyHeight;

@end

@implementation TTMasterViewController

-(void)swapViews
{
    if (self.bodyState == TTMasterViewControllerBodyContentStateArbTables)
        [self setToBodyState:(TTMasterViewControllerBodyContentStateDepthTables)];
    else if (self.bodyState == TTMasterViewControllerBodyContentStateDepthTables)
        [self setToBodyState:(TTMasterViewControllerBodyContentStateArbTables)];
    else
        RUDLog(@"No state set");
}

-(void)setToBodyState:(TTMasterViewControllerBodyContentState)bodyState// WithCompletion:(void (^)())completion
{
    NSMutableDictionary* animationDictionaryOut = [NSMutableDictionary dictionaryWithCapacity:2];
    NSMutableDictionary* animationDictionaryIn = [NSMutableDictionary dictionaryWithCapacity:2];
    switch (bodyState) {
        case TTMasterViewControllerBodyContentStateArbTables:
            [animationDictionaryOut setObject:NSViewAnimationEffectKey forKey:NSViewAnimationFadeOutEffect];
            [animationDictionaryOut setObject:self.depthGridView forKey:@"NSViewAnimationTargetKey"];
            
            [animationDictionaryIn setObject:self.arbGridView forKey:@"NSViewAnimationTargetKey"];
            [animationDictionaryIn setObject:NSViewAnimationEffectKey forKey:NSViewAnimationFadeInEffect];
            break;
            
        case TTMasterViewControllerBodyContentStateDepthTables:
            [animationDictionaryOut setObject:NSViewAnimationEffectKey forKey:NSViewAnimationFadeOutEffect];
            [animationDictionaryOut setObject:self.arbGridView forKey:@"NSViewAnimationTargetKey"];
            
            [animationDictionaryIn setObject:self.depthGridView forKey:@"NSViewAnimationTargetKey"];
            [animationDictionaryIn setObject:NSViewAnimationEffectKey forKey:NSViewAnimationFadeInEffect];
            break;
            
        default:
            break;
    }
    NSViewAnimation* theAnim = [[NSViewAnimation alloc]initWithViewAnimations:@[animationDictionaryOut, animationDictionaryIn]];
    [theAnim setDuration:1.5];    // One and a half seconds.
    [theAnim setAnimationCurve:NSAnimationEaseIn];
    [theAnim startAnimation];
    _bodyState = bodyState;
//    completion();
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setStatusBarView:[TTStatusBarView new]];
        [self addSubview:_statusBarView];
        [self setControlBoxView:[TTAPIControlBoxView sharedInstance]];
        [self addSubview:_controlBoxView];
        [self setAccountBox:[TTAccountBox new]];
        [self addSubview:self.accountBox];

        CGFloat statusBarHeight = floorf(CGRectGetHeight(frameRect) / 8);
        [_statusBarView setFrame:(NSRect){0, CGRectGetHeight(frameRect) - statusBarHeight, CGRectGetWidth(frameRect), statusBarHeight}];
        [_statusBarView setNeedsLayout:YES];
        
        _centerBodyHeight = floorf((CGRectGetHeight(frameRect) / 8) * 4) - 40;
        
        _centerBodyRect = (NSRect){0, CGRectGetHeight(frameRect) - _statusBarView.frame.size.height - _centerBodyHeight, CGRectGetWidth(frameRect), _centerBodyHeight};
        
        [_controlBoxView setFrame:(NSRect){0, 0, CGRectGetWidth(frameRect) / 4, CGRectGetHeight(frameRect) - statusBarHeight - _centerBodyHeight}];
        
        [self setArbGridView:[[TTArbGridView alloc]initWithFrame:_centerBodyRect]];
        [self addSubview:self.arbGridView];
        
        [self setDepthGridView:[[TTDepthGridView alloc]initWithFrame:_centerBodyRect]];
        [self.depthGridView setAlphaValue:0.0];
        [self addSubview:self.depthGridView];
        
        _bodyState = TTMasterViewControllerBodyContentStateArbTables;
        
        NSRect acctBoxFrame = (NSRect){CGRectGetWidth(_controlBoxView.frame), 0, ((CGRectGetWidth(frameRect) / 4) * 3), CGRectGetHeight(frameRect) - statusBarHeight - _centerBodyHeight};
        [_accountBox setFrame:acctBoxFrame];
    }
    return self;
}

@end
