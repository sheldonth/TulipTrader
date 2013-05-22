//
//  TTMasterViewController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/6/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTMasterViewController.h"
#import "TTStatusBarView.h"
#import "RUConstants.h"
#import "TTFrameConstants.h"
#import "TTArbitrageStackView.h"
#import "TTGoxCurrencyController.h"
#import "TTAPIControlBoxView.h"

#define TTArbitrageStackViewHeight 375 // Consider making this dynamic when you can drag resize the screen.
//#define TTControlBoxHeight 355

@interface TTMasterViewController ()

@property(nonatomic, retain)TTStatusBarView* statusBarView;
@property(nonatomic, retain)NSMutableArray* arbitrageStackViewsArray;
@property(nonatomic, retain)TTAPIControlBoxView* controlBoxView;

@end

@implementation TTMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setStatusBarView:[TTStatusBarView new]];
        [self.view addSubview:_statusBarView];
        [self setArbitrageStackViewsArray:[NSMutableArray array]];
        NSArray* __activeCurrencies = [TTGoxCurrencyController activeCurrencys];
        [__activeCurrencies enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
            TTArbitrageStackView* stackView = [TTArbitrageStackView new];
            [stackView setBaseCurrency:currencyFromString(obj)];
            [self.view addSubview:stackView];
            [self.arbitrageStackViewsArray addObject:stackView];
        }];
        [self setControlBoxView:[TTAPIControlBoxView sharedInstance]];
        [self.view addSubview:_controlBoxView];
    }
    return self;
}

-(void)setViewFrameAndInformSubviews:(NSRect)newFrame
{
    CGFloat statusBarHeight = CGRectGetHeight(newFrame) / 8;
    [self.view setFrame:newFrame];
    [_statusBarView setFrame:(NSRect){0, CGRectGetHeight(newFrame) - statusBarHeight, CGRectGetWidth(newFrame), statusBarHeight}];
    [_statusBarView setNeedsLayout:YES];
    [_controlBoxView setFrame:(NSRect){0, 0, CGRectGetWidth(newFrame) / 2, CGRectGetHeight(newFrame) - statusBarHeight - TTArbitrageStackViewHeight}];
    [self.arbitrageStackViewsArray enumerateObjectsUsingBlock:^(TTArbitrageStackView* obj, NSUInteger idx, BOOL *stop) {
        [obj setFrame:(NSRect){(floor(CGRectGetWidth(newFrame) / self.arbitrageStackViewsArray.count)) * idx, CGRectGetHeight(newFrame) - statusBarHeight - TTArbitrageStackViewHeight, floor(CGRectGetWidth(newFrame) / self.arbitrageStackViewsArray.count), TTArbitrageStackViewHeight}];
    }];
}

@end
