//
//  TTDepthGridViewColumnView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/17/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTDepthGridViewColumnView.h"
#import "TTGoxPrivateMessageController.h"
#import "Ticker.h"
#import "RUConstants.h"

#define scrollViewTopOffset 15.f
#define scrollViewBottomOffset 15.f

@interface TTDepthGridViewColumnView()

@property(nonatomic, retain)TTDepthStackView* stackView;
@property(nonatomic, retain)NSScrollView* graphScrollView;
@property(nonatomic, retain)NSTrackingArea* trackingArea;
@property(nonatomic, retain)NSButton* infoButton;

@end

@implementation TTDepthGridViewColumnView

-(void)redrawXAxisWithBidSideTicks:(NSArray *)bidTicks sellSideTicks:(NSArray *)sellTicks
{
    
}

-(void)reloadDepthWithTickerNotification:(NSNotification*)notification
{
    Ticker* t = [notification.userInfo objectForKey:@"Ticker"];
    if ([bitcoinTickerChannelNameForCurrency(self.currency) isEqualToString:t.channel_name])
        [self.stackView reload];
}

-(void)reloadDepthWithTradeNotification:(NSNotification*)notification
{
    Trade* t = [notification.userInfo objectForKey:@"Trade"];
    if (currencyFromNumber(t.currency) == self.currency)
        [self.stackView reload];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:TTGoxWebsocketTradeNotificationString];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setGraphScrollView:[[NSScrollView alloc]initWithFrame:(NSRect){0, scrollViewBottomOffset, CGRectGetWidth(frame), CGRectGetHeight(frame) - (scrollViewBottomOffset + scrollViewTopOffset)}]];
        [_graphScrollView setHasVerticalScroller:YES];
        [_graphScrollView setDrawsBackground:NO];
        [self setStackView:[[TTDepthStackView alloc]initWithFrame:_graphScrollView.frame]];
        [_stackView setXAxisDelegate:self];
        [_graphScrollView setDocumentView:_stackView];
        [self addSubview:_graphScrollView];
        
        [self setInfoButton:[[NSButton alloc]initWithFrame:(NSRect){(CGRectGetWidth(frame) / 2) - 7.5, CGRectGetHeight(frame) - 17, 15, 15}]];
        [_infoButton setButtonType:NSMomentaryLightButton];
        [_infoButton setBordered:NO];
        NSImage* infoIcn = [NSImage imageNamed:@"infoBtn"];
        [infoIcn setSize:(NSSize){15, 15}];
        [self.infoButton setImage:infoIcn];
        [self.infoButton setImagePosition:NSImageOnly];
        [self addSubview:self.infoButton];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadDepthWithTradeNotification:) name:TTGoxWebsocketTradeNotificationString object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadDepthWithTickerNotification:) name:TTGoxWebsocketTickerNotificationString object:nil];
    }
    
    return self;
}

-(void)setCurrency:(TTGoxCurrency)currency
{
    [_stackView setCurrency:currency];
    _currency = currency;
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//    // Drawing code here.
//}

@end
