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
#import "TTAppDelegate.h"
#import "TTDepthInfoPopoverViewController.h"
#import "JNWLabel.h"

#define scrollViewTopOffset 15.f
#define scrollViewBottomOffset 15.f

@interface TTDepthGridViewColumnView()

@property(nonatomic, retain)TTDepthStackView* stackView;
@property(nonatomic, retain)NSScrollView* graphScrollView;
@property(nonatomic, retain)NSTrackingArea* trackingArea;
@property(nonatomic, retain)NSButton* infoButton;
@property(nonatomic, retain)NSDate* lastReload;

@property(nonatomic)BOOL priceLabelShowing;
@property(nonatomic)JNWLabel* priceLabel;

@property(nonatomic, retain)TTDepthInfoPopoverViewController* popoverViewController;
@property(nonatomic, retain)NSPopover* popover;

@end

@implementation TTDepthGridViewColumnView

#pragma mark - Public Methods

-(void)reload
{
    [self.stackView reload];
}

#pragma mark - NSPopoverDelegate methods


#pragma mark - TTDepthStackViewLabelingDelegate methods

-(void)shouldEndShowingInfoPane
{
    if (self.popover)
        [self.popover close];
}

-(void)shouldEndShowingPrice
{
    if (self.priceLabelShowing)
    {
        [NSAnimationContext beginGrouping];
        NSAnimationContext* curContext = [NSAnimationContext currentContext];
        [curContext setDuration:0.1f];
        [self.infoButton.animator setAlphaValue:1.f];
        [self.priceLabel.animator setAlphaValue:0.f];
        [curContext setCompletionHandler:^{
            [self setPriceLabelShowing:NO];
        }];
        [NSAnimationContext endGrouping];
    }
}

-(void)updatePriceString:(NSString *)priceString
{
    if (!self.priceLabelShowing)
    {
        [NSAnimationContext beginGrouping];
        NSAnimationContext* curContext = [NSAnimationContext currentContext];
        [curContext setDuration:0.1f];
        [self.infoButton.animator setAlphaValue:0.f];
        [self.priceLabel.animator setAlphaValue:1.f];
        [curContext setCompletionHandler:^{
            [self setPriceLabelShowing:YES];
        }];
        [NSAnimationContext endGrouping];
    }
    [self.priceLabel setText:priceString];
}

-(void)redrawXAxisWithBidSideTicks:(NSArray *)bidTicks sellSideTicks:(NSArray *)sellTicks
{
    
}

-(void)showInfoPopover:(NSButton*)sender
{
    if (!_popoverViewController)
        _popoverViewController = [[TTDepthInfoPopoverViewController alloc]initWithNibName:nil bundle:nil andViewSize:(NSSize){150, 75}];
    if (self.popover)
        [self.popover close];
    else
    {
        [self setPopover:[[NSPopover alloc]init]];
        [_popover setContentViewController:_popoverViewController];
        [_popover setDelegate:self];
        [_popover setBehavior:NSPopoverBehaviorTransient];
    }
    [_popover showRelativeToRect:sender.frame ofView:self preferredEdge:NSMaxXEdge];
}

#pragma mark - NotificationCenter methods

-(void)observeDepthNotification:(NSNotification*)sender
{
    NSDictionary* notificationDict = [sender.userInfo objectForKey:@"DepthDictionary"];
    NSDictionary* depthDict = [notificationDict objectForKey:@"depth"];
    TTGoxCurrency currency = currencyFromString([depthDict objectForKey:@"currency"]);
    if (self.currency == currency)
        [self.stackView processDepthDictionary:depthDict];
}

-(void)reloadDepthWithTickerNotification:(NSNotification*)notification
{
    Ticker* t = [notification.userInfo objectForKey:@"Ticker"];
    if ([bitcoinTickerChannelNameForCurrency(self.currency) isEqualToString:t.channel_name])
        if ([self.lastReload timeIntervalSinceNow] < -30.f)
        {
//            [self.stackView reload];
            [self setLastReload:[NSDate date]];
        }
}

-(void)reloadDepthWithTradeNotification:(NSNotification*)notification
{
    Trade* t = [notification.userInfo objectForKey:@"Trade"];
    if (currencyFromNumber(t.currency) == self.currency)
        if ([self.lastReload timeIntervalSinceNow] < -30.f)
        {
            [self setLastReload:[NSDate date]];
//            [self.stackView reload];
        }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:TTGoxWebsocketTradeNotificationString];
//    [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:TTGoxWebsocketDepthNotificationString];
    [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:TTGoxWebsocketTickerNotificationString];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setGraphScrollView:[[NSScrollView alloc]initWithFrame:(NSRect){0, scrollViewBottomOffset, CGRectGetWidth(frame), CGRectGetHeight(frame) - (scrollViewBottomOffset + scrollViewTopOffset)}]];
        [_graphScrollView setHasVerticalScroller:YES];
        [_graphScrollView setDrawsBackground:NO];
        [self setStackView:[[TTDepthStackView alloc]initWithFrame:_graphScrollView.frame]];
        [_stackView setLabelingDelegate:self];
        [_graphScrollView setDocumentView:_stackView];
        [self addSubview:_graphScrollView];
        
        [self setInfoButton:[[NSButton alloc]initWithFrame:(NSRect){(CGRectGetWidth(frame) / 2) - 7.5, CGRectGetHeight(frame) - 17, 15, 15}]];
        [_infoButton setButtonType:NSMomentaryLightButton];
        [_infoButton setBordered:NO];
        NSImage* infoIcn = [NSImage imageNamed:@"infoBtn"];
        [infoIcn setSize:(NSSize){15, 15}];
        [self.infoButton setImage:infoIcn];
        [self.infoButton setImagePosition:NSImageOnly];
        [self.infoButton setTarget:self];
        [self.infoButton setAction:@selector(showInfoPopover:)];
        [self addSubview:self.infoButton];
        
        [self setPriceLabel:[[JNWLabel alloc]initWithFrame:(NSRect){0, CGRectGetHeight(frame) - scrollViewTopOffset, CGRectGetWidth(frame), scrollViewTopOffset}]];
        [self.priceLabel setTextAlignment:NSCenterTextAlignment];
        [self.priceLabel setAlphaValue:0.f];
        [self addSubview:self.priceLabel];
        
        [self setPriceLabelShowing:NO];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadDepthWithTradeNotification:) name:TTGoxWebsocketTradeNotificationString object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadDepthWithTickerNotification:) name:TTGoxWebsocketTickerNotificationString object:nil];
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(observeDepthNotification:) name:TTGoxWebsocketDepthNotificationString object:nil];
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
