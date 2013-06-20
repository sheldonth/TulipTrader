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
#import "TTOperationsController.h"


@interface TTMasterViewController ()

@property(nonatomic, retain)TTStatusBarView* statusBarView;
@property(nonatomic, retain)NSMutableArray* arbitrageStackViewsArray;
@property(nonatomic)NSRect centerBodyRect;
@property(nonatomic)CGFloat centerBodyHeight;
@property(nonatomic, retain)TTGoxPrivateMessageController* privateMessageController;

@end

@implementation TTMasterViewController

#pragma mark - TTGoxSocketPrivateMessageDelegate methods

-(void)lagObserved:(NSDictionary *)lagDict
{
    
}

-(void)depthChangeObserved:(NSDictionary *)depthDictionary
{
    RUDLog(@"Depth");
}

-(void)tradeOccuredForCurrency:(TTGoxCurrency)currency tradeData:(Trade *)trade
{
    RUDLog(@"Trade");
}

-(void)tickerObserved:(Ticker *)ticker forChannel:(NSString *)channel
{
    // For now, NSNotifications are handling informing the currencyboxes. Refactor that eventually.
}

#pragma mark - TTGoxSocketMessageDelegate methods

-(void)shouldExamineResponseDictionary:(NSDictionary *)dictionary ofMessageType:(TTGoxSocketMessageType)type
{
    switch (type) {
        case TTGoxSocketMessageTypeResult:
            RUDLog(@"result");
            break;
            
        case TTGoxSocketMessageTypePrivate:
            [self.privateMessageController shouldExamineMarketDataDictionary:dictionary];
            break;
            
        case TTGoxSocketMessageTypeRemark:
            RUDLog(@"remark");
            break;
            
        case TTGoxSocketMessageTypeNone:
            RUDLog(@"Message Type None");
            break;
            
        default:
            break;
    }
}

-(void)swapViews
{
    if (self.bodyState == TTMasterViewControllerBodyContentStateArbTables)
        [self setToBodyState:(TTMasterViewControllerBodyContentStateDepthTables)];
    else if (self.bodyState == TTMasterViewControllerBodyContentStateDepthTables)
        [self setToBodyState:(TTMasterViewControllerBodyContentStateArbTables)];
    else
        RUDLog(@"No state set");
}

-(void)setToBodyState:(TTMasterViewControllerBodyContentState)bodyState
{
    if (![self.subviews containsObject:self.arbGridView])
        [self addSubview:self.arbGridView];
    
    if (![self.subviews containsObject:self.depthGridView])
        [self addSubview:self.depthGridView];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext]setDuration:0.3];
    switch (bodyState) {
        case TTMasterViewControllerBodyContentStateArbTables:
        {
            [[self.depthGridView animator] setAlphaValue:0.0];
            [[self.arbGridView animator]setAlphaValue:1.0];
            [[NSAnimationContext currentContext]setCompletionHandler:^{
                [self.depthGridView removeFromSuperview];
            }];
            break;
        }
            
        case TTMasterViewControllerBodyContentStateDepthTables:
        {
            if (!self.depthGridView)
            {
                [self setDepthGridView:[[TTDepthGridView alloc]initWithFrame:_centerBodyRect]];
                [self.depthGridView setAlphaValue:0.0];
                [self addSubview:self.depthGridView];
            }
            [[self.depthGridView animator]setAlphaValue:1.0];
            [[self.arbGridView animator]setAlphaValue:0.0];
            [[NSAnimationContext currentContext]setCompletionHandler:^{
                [self.arbGridView removeFromSuperview];
            }];
            break;
        }
        default:
            break;
    }
    [NSAnimationContext endGrouping];
    [self willChangeValueForKey:@"bodyState"];
    _bodyState = bodyState;
    [self didChangeValueForKey:@"bodyState"];
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        CGFloat statusBarHeight = floorf(CGRectGetHeight(frameRect) / 8);

        _centerBodyHeight = floorf((CGRectGetHeight(frameRect) / 8) * 4) - 40;

        _centerBodyRect = (NSRect){0, CGRectGetHeight(frameRect) - statusBarHeight - _centerBodyHeight, CGRectGetWidth(frameRect), _centerBodyHeight};
        
        [self setStatusBarView:[[TTStatusBarView alloc]initWithFrame:(NSRect){0, CGRectGetHeight(frameRect) - statusBarHeight, CGRectGetWidth(frameRect), statusBarHeight}]];
        [self addSubview:_statusBarView];
        
        [self setControlBoxView:[TTAPIControlBoxView sharedInstance]];
        [self addSubview:_controlBoxView];
        [_controlBoxView setFrame:(NSRect){0, 0, CGRectGetWidth(frameRect) / 4, CGRectGetHeight(frameRect) - statusBarHeight - _centerBodyHeight}];
        
        [self setAccountBox:[[TTAccountBox alloc]initWithFrame:(NSRect){CGRectGetWidth(_controlBoxView.frame), 0, ((CGRectGetWidth(frameRect) / 4) * 3), CGRectGetHeight(frameRect) - statusBarHeight - _centerBodyHeight}]];
        [self.accountBox setFrame:_accountBox.frame];
        [self addSubview:self.accountBox];
        
        [self.accountBox loadSequential];
        
        [self setArbGridView:[[TTArbGridView alloc]initWithFrame:_centerBodyRect]];
        [self addSubview:self.arbGridView];
        
        _bodyState = TTMasterViewControllerBodyContentStateArbTables;
        
        [self setSocketController:[TTGoxSocketController new]];
        [_socketController setMessageDelegate:self];
        [_socketController open];
        
        [self setPrivateMessageController:[TTGoxPrivateMessageController new]];
        [_privateMessageController setLagDelegate:self];
        [_privateMessageController setDepthDelegate:self];
        [_privateMessageController setTradeDelegate:self];
        [_privateMessageController setTickerDelegate:self];
    }
    return self;
}

@end
