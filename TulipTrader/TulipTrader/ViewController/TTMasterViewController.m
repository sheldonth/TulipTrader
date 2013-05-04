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

#define TTArbitrageStackViewHeight 600 // Consider making this dynamic when you can drag resize the screen.

@interface TTMasterViewController ()

@property(nonatomic, retain)TTStatusBarView* statusBarView;
@property(nonatomic, retain)NSMutableArray* arbitrageStackViewsArray;

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
//            if (idx == 2)
            [self.view addSubview:stackView];
            [self.arbitrageStackViewsArray addObject:stackView];
        }];
    }
    
    return self;
}

-(void)setViewFrameAndInformSubviews:(NSRect)newFrame
{
    [self.view setFrame:newFrame];
    [_statusBarView setFrame:(NSRect){0, CGRectGetHeight(newFrame) - kTTStatusBarHeight, CGRectGetWidth(newFrame), kTTStatusBarHeight}];
    [_statusBarView setNeedsLayout:YES];
    
    [self.arbitrageStackViewsArray enumerateObjectsUsingBlock:^(TTArbitrageStackView* obj, NSUInteger idx, BOOL *stop) {
        [obj setFrame:(NSRect){(floor(CGRectGetWidth(newFrame) / self.arbitrageStackViewsArray.count)) * idx, CGRectGetHeight(newFrame) - kTTStatusBarHeight - TTArbitrageStackViewHeight, floor(CGRectGetWidth(newFrame) / self.arbitrageStackViewsArray.count), TTArbitrageStackViewHeight}];
    }];
}

@end
