//
//  TTAccountBalancesBox.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/25/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTAccountBalancesBox.h"
#import "JNWLabel.h"

@interface TTAccountBalancesBox()

@property(nonatomic, retain)NSImage* icn1;
@property(nonatomic, retain)NSImage* icn;


@end

static NSFont* accountFont;

@implementation TTAccountBalancesBox

+(void)initialize
{
    if (self == [TTAccountBalancesBox class])
    {
        accountFont = [NSFont fontWithName:@"Menlo" size:24.f];
    }
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAccountValuesReloadButton:[[NSButton alloc]initWithFrame:NSZeroRect]];
        [self.accountValuesReloadButton setImagePosition:NSImageOnly];
        [self.accountValuesReloadButton setBordered:NO];
        
        [self setWalletSelectionPopUpButton:[[NSPopUpButton alloc]initWithFrame:NSZeroRect pullsDown:NO]];
        [self.contentView addSubview:_walletSelectionPopUpButton];
        
        [self.accountValuesReloadButton.cell setImageScaling:NSImageScaleProportionallyDown];
        NSImage* btnImage = [NSImage imageNamed:@"refreshIconLG.png"];
        [btnImage setSize:self.accountValuesReloadButton.frame.size];
        [self.accountValuesReloadButton setImage:btnImage];
        [self.contentView addSubview:self.accountValuesReloadButton];
        
        [self setAccountValueLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [self.accountValueLabel setFont:accountFont];
        [self.accountValueLabel setTextAlignment:NSCenterTextAlignment];
        [self.accountValueLabel setAutoresizingMask:(NSViewMinXMargin | NSViewMaxXMargin)];
        [self.contentView addSubview:self.accountValueLabel];

        [self setPrimaryCurrencyLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [self.primaryCurrencyLabel setFont:accountFont];
        [self.primaryCurrencyLabel setTextAlignment:NSCenterTextAlignment];
        [self.contentView addSubview:self.primaryCurrencyLabel];


        [self setBitcoinCurrencyLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [self.bitcoinCurrencyLabel setFont:accountFont];
        [self.bitcoinCurrencyLabel setTextAlignment:NSCenterTextAlignment];
        [self.contentView addSubview:self.bitcoinCurrencyLabel];
    
        [self setFastBuyButton:[[NSButton alloc]initWithFrame:NSZeroRect]];
        [self setIcn1:[NSImage imageNamed:@"arrow_left.png"]];
        [_fastBuyButton setImage:_icn1];
        [self.contentView addSubview:_fastBuyButton];
        
        [self setFastSellButton:[[NSButton alloc]initWithFrame:NSZeroRect]];
        [self setIcn:[NSImage imageNamed:@"arrow_right.png"]];
        [_fastSellButton setImage:_icn];
        [self.contentView addSubview:_fastSellButton];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [self.accountValuesReloadButton setFrame:(NSRect){CGRectGetWidth([self.contentView frame]) - 40, CGRectGetHeight([self.contentView frame]) - 30, 25, 25}];
    [_accountValueLabel setFrame:(NSRect){0, CGRectGetHeight(self.frame) - 40, CGRectGetWidth(self.frame), 25}];
    [_walletSelectionPopUpButton setFrame:(NSRect){15, CGRectGetHeight([self.contentView frame]) - 30, 80, 25}];
    [_primaryCurrencyLabel setFrame:(NSRect){10, CGRectGetMinY(_accountValueLabel.frame) - 50, CGRectGetWidth(self.frame) / 2, 25}];
    [_bitcoinCurrencyLabel setFrame:(NSRect){CGRectGetWidth(self.frame) / 2, CGRectGetMinY(_accountValueLabel.frame) - 50, CGRectGetWidth(self.frame) / 2, 25}];
    [_fastBuyButton setFrame:(NSRect){5, 5, 20, 35}];
    [_fastSellButton setFrame:(NSRect){CGRectGetWidth([self.contentView frame]) - 25, 5, 20, 35}];
    [_icn1 setSize:_fastBuyButton.frame.size];
    [_icn setSize:_fastSellButton.frame.size];
}

@end
