//
//  TTAccountWindow.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/15/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTAccountWindow.h"
#import "TTGoxHTTPController.h"
#import "RUConstants.h"
#import "JNWLabel.h"
#import "TTGoxWallet.h"
#import "TTLabelCellView.h"

#define primaryCurrency @"USD"

@interface TTAccountWindow()

@property(nonatomic, retain)TTGoxHTTPController* httpController;
@property(nonatomic, retain)JNWLabel* accountValueLabel;
@property(nonatomic, retain)JNWLabel* primaryCurrencyLabel;
@property(nonatomic, retain)JNWLabel* bitcoinCurrencyLabel;
@property(nonatomic, retain)NSMutableArray* walletsArray;
@property(nonatomic, retain)NSBox* accountBalancesBox;

@property(nonatomic, retain)NSScrollView* accountTransactionsScrollView;
@property(nonatomic, retain)NSTableView* accountTransactionsTableView;

@end

@implementation TTAccountWindow

static NSFont* accountFont;

+(void)initialize
{
    if (self == [TTAccountWindow class])
    {
        accountFont = [NSFont fontWithName:@"Menlo" size:24.f];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"bids"])
    {
        
    }
    else if ([keyPath isEqualToString:@"asks"])
    {
        
    }
    else if ([keyPath isEqualToString:@"lastTicker"])
    {
        [self setAccountValueLabel];
    }
}

-(void)setupLabels
{
    if (!_accountValueLabel)
    {
        [self setAccountValueLabel:[[JNWLabel alloc]initWithFrame:(NSRect){0, CGRectGetHeight(self.accountBalancesBox.frame) - 40, CGRectGetWidth(self.frame), 25}]];
        [self.accountValueLabel setFont:accountFont];
        [self.accountValueLabel setTextAlignment:NSCenterTextAlignment];
        [self.accountBalancesBox.contentView addSubview:self.accountValueLabel];
    }
    if (!self.primaryCurrencyLabel)
    {
        [self setPrimaryCurrencyLabel:[[JNWLabel alloc]initWithFrame:(NSRect){0, CGRectGetMinY(_accountValueLabel.frame) - 50, CGRectGetWidth(self.frame) / 2, 25}]];
        [self.primaryCurrencyLabel setFont:accountFont];
        [self.primaryCurrencyLabel setTextAlignment:NSCenterTextAlignment];
        [self.accountBalancesBox.contentView addSubview:self.primaryCurrencyLabel];
    }
    if (!self.bitcoinCurrencyLabel)
    {
        [self setBitcoinCurrencyLabel:[[JNWLabel alloc]initWithFrame:(NSRect){CGRectGetWidth(self.accountBalancesBox.frame) / 2, CGRectGetMinY(_accountValueLabel.frame) - 50, CGRectGetWidth(self.frame) / 2, 25}]];
        [self.bitcoinCurrencyLabel setFont:accountFont];
        [self.bitcoinCurrencyLabel setTextAlignment:NSCenterTextAlignment];
        [self.accountBalancesBox.contentView addSubview:self.bitcoinCurrencyLabel];
    }
}

-(double)walletBalanceForCurrency:(TTCurrency)currency
{
    NSInteger idx = [self.walletsArray indexOfObjectPassingTest:^BOOL(TTGoxWallet* obj, NSUInteger idx, BOOL *stop) {
        if (obj.currency == currency)
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (idx == NSNotFound)
        return 0.f;
    else
    {
        double b = [[[[self.walletsArray objectAtIndex:idx]balance]value]floatValue];
        return b;
    }
}

-(void)setAccountValueLabel
{
    double btcInDollars = ([self walletBalanceForCurrency:TTCurrencyBTC] * self.orderbook.lastTicker.last.value.floatValue);
    double acctVal = btcInDollars + [self walletBalanceForCurrency:TTCurrencyUSD];
    [self.accountValueLabel setText:RUStringWithFormat(@"$%.2f", acctVal)];
    [self.primaryCurrencyLabel setText:RUStringWithFormat(@"%.5fBTC", [self walletBalanceForCurrency:TTCurrencyBTC])];
    [self.bitcoinCurrencyLabel setText:RUStringWithFormat(@"$%.2f", [self walletBalanceForCurrency:TTCurrencyUSD])];
}

-(void)reloadAccountData
{
    [_httpController loadAccountDataWithCompletion:^(NSDictionary *accountInformationDictionary) {
        [self setupLabels];
        [self.walletsArray removeAllObjects];
        NSDictionary* walletsDic = [accountInformationDictionary objectForKey:@"Wallets"];
        [walletsDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            TTGoxWallet* wallet = [TTGoxWallet walletFromDictionary:obj];
            [wallet setCurrency:currencyFromString(key)];
            [self.walletsArray addObject:wallet];
        }];
    } andFailBlock:^(NSError *e) {
        [self.accountValueLabel setText:RUStringWithFormat(@"--.--")];
        [self.primaryCurrencyLabel setText:RUStringWithFormat(@"--.--")];
        [self.bitcoinCurrencyLabel setText:RUStringWithFormat(@"--.--")];
    }];
}

-(void)windowDidResize:(NSNotification *)notification
{
    
}

#pragma mark nstableviewdelegate/datasource

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 20.f;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    TTLabelCellView* labelCellView = [[TTLabelCellView alloc]initWithFrame:(NSRect){0, 0, 20.f, 20.f}];
    [labelCellView setValueString:@"fuck"];
    return labelCellView;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return 5;
}

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self)
    {
        [self setHttpController:[[TTGoxHTTPController alloc]init]];
        [self reloadAccountData];
        [self setDelegate:self];
        [self setWalletsArray:[NSMutableArray array]];
        
        [self setAccountBalancesBox:[[NSBox alloc]initWithFrame:(NSRect){0, CGRectGetHeight(self.frame) - 150, CGRectGetWidth(self.frame), 100}]];
        [self.accountBalancesBox setTitlePosition:NSNoTitle];
        [self.contentView addSubview:_accountBalancesBox];
        
        [self setAccountTransactionsScrollView:[[NSScrollView alloc]initWithFrame:(NSRect){0, CGRectGetMinY(_accountBalancesBox.frame) - 130, CGRectGetWidth(self.frame), 150}]];
        [self.accountTransactionsScrollView setHasVerticalScroller:YES];
        [self.accountTransactionsScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        [self setAccountTransactionsTableView:[[NSTableView alloc]initWithFrame:(NSRect){0, 0, CGRectGetWidth(self.frame), 150}]];
        [_accountTransactionsTableView setDataSource:self];
        [_accountTransactionsTableView setDelegate:self];
        [_accountTransactionsTableView setUsesAlternatingRowBackgroundColors:YES];
        [_accountTransactionsTableView setGridStyleMask:(NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask)];
        [_accountTransactionsTableView setAllowsColumnReordering:YES];
        [_accountTransactionsTableView setAllowsColumnResizing:YES];
        [_accountTransactionsTableView setAllowsExpansionToolTips:YES];
        [_accountTransactionsTableView setAllowsMultipleSelection:YES];
        [_accountTransactionsTableView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        [self.accountTransactionsScrollView setDocumentView:_accountTransactionsTableView];
        [self.contentView addSubview:_accountTransactionsScrollView];
    
        [self.accountTransactionsTableView reloadData];
    }
    return self;
}

-(void)setOrderbook:(TTOrderBook *)orderbook
{
    [self willChangeValueForKey:@"orderbook"];
    _orderbook = orderbook;
    [self didChangeValueForKey:@"orderbook"];
    [orderbook addObserver:self forKeyPath:@"bids" options:NSKeyValueObservingOptionNew context:nil];
    [orderbook addObserver:self forKeyPath:@"asks" options:NSKeyValueObservingOptionNew context:nil];
    [orderbook addObserver:self forKeyPath:@"lastTicker" options:NSKeyValueObservingOptionNew context:nil];
}

@end
