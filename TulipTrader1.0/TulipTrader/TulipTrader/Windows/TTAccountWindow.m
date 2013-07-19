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
#import "TTTick.h"
#import "TTGoxTransaction.h"
#import "TTGoxTransactionTrade.h"

//#define primaryCurrency @"USD"

@interface TTAccountWindow()

@property(nonatomic, retain)TTGoxHTTPController* httpController;
@property(nonatomic, retain)JNWLabel* accountValueLabel;
@property(nonatomic, retain)JNWLabel* primaryCurrencyLabel;
@property(nonatomic, retain)JNWLabel* bitcoinCurrencyLabel;
@property(nonatomic, retain)NSMutableArray* walletsArray;
@property(nonatomic, retain)NSBox* accountBalancesBox;

@property(nonatomic, retain)NSPopUpButton* walletSelectionPopUpButton;

@property(nonatomic, retain)NSScrollView* accountTransactionsScrollView;
@property(nonatomic, retain)NSTableView* accountTransactionsTableView;

@property(nonatomic, retain)NSArray* tableColumnTitles;
@property(nonatomic, retain)NSMutableArray* tableColumns;

@property(nonatomic, retain)NSButton* accountValuesReloadButton;

@property(nonatomic, retain)NSButton* buyActionButton;
@property(nonatomic, retain)NSButton* sellActionButton;

@property(nonatomic, retain)NSButton* marketOrderButton;
@property(nonatomic, retain)NSButton* limitOrderButton;

@property(nonatomic, retain)JNWLabel* orderAmountlabel;
@property(nonatomic, retain)JNWLabel* orderPriceLabel;

@property(nonatomic, retain)NSTextField* orderAmountTextField;
@property(nonatomic, retain)NSTextField* orderPriceTextField;

@property(nonatomic, retain)NSButton* fastBuyButton;
@property(nonatomic, retain)NSButton* fastSellButton;

@property(nonatomic, retain)NSButton* tradeExecutionButton;

@property(nonatomic)TTCurrency currentCurrency;

@end

@implementation TTAccountWindow

static NSFont* accountFont;
static NSFont* accountActionsFont;

+(void)initialize
{
    if (self == [TTAccountWindow class])
    {
        accountFont = [NSFont fontWithName:@"Menlo" size:24.f];
        accountActionsFont = [NSFont fontWithName:@"Menlo" size:16.f];
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
        [self setAccountValueLabels];
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
        [self setPrimaryCurrencyLabel:[[JNWLabel alloc]initWithFrame:(NSRect){10, CGRectGetMinY(_accountValueLabel.frame) - 50, CGRectGetWidth(self.frame) / 2, 25}]];
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
    if (!self.fastBuyButton)
    {
        [self setFastBuyButton:[[NSButton alloc]initWithFrame:(NSRect){5, 5, 20, 35}]];
        NSImage* icn = [NSImage imageNamed:@"arrow_left.png"];
        [icn setSize:_fastBuyButton.frame.size];
        [_fastBuyButton setImage:icn];
        [self.accountBalancesBox.contentView addSubview:_fastBuyButton];
    }
    if (!self.fastSellButton)
    {
        [self setFastSellButton:[[NSButton alloc]initWithFrame:(NSRect){CGRectGetWidth([self.accountBalancesBox.contentView frame]) - 25, 5, 20, 35}]];
        NSImage* icn = [NSImage imageNamed:@"arrow_right.png"];
        [icn setSize:_fastSellButton.frame.size];
        [_fastSellButton setImage:icn];
        [self.accountBalancesBox.contentView addSubview:_fastSellButton];
    }
}

-(TTGoxWallet*)walletForCurrency:(TTCurrency)currency
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
        return nil;
    else
    {
        return [self.walletsArray objectAtIndex:idx];
    }
}

-(void)setAccountValueLabels
{
    double btcInDollars = ([self walletForCurrency:TTCurrencyBTC].balance.value.floatValue * self.orderbook.lastTicker.last.value.floatValue);
    double acctVal = btcInDollars + [self walletForCurrency:TTCurrencyUSD].balance.value.floatValue;
    [self.accountValueLabel setText:RUStringWithFormat(@"$%.2f", acctVal)];
    [self.primaryCurrencyLabel setText:RUStringWithFormat(@"%.5fBTC", [[[[self walletForCurrency:TTCurrencyBTC]balance]value]floatValue])];
    [self.bitcoinCurrencyLabel setText:RUStringWithFormat(@"$%.2f", [[[[self walletForCurrency:TTCurrencyUSD]balance]value]floatValue])];
}

-(void)reloadAccountData
{
    [_httpController loadAccountDataWithCompletion:^(NSDictionary *accountInformationDictionary) {
        [self setupLabels];
        [self.walletsArray removeAllObjects];
        [self.walletSelectionPopUpButton removeAllItems];
        NSDictionary* walletsDic = [accountInformationDictionary objectForKey:@"Wallets"];
        [walletsDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            TTGoxWallet* wallet = [TTGoxWallet walletFromDictionary:obj];
            [wallet setCurrency:currencyFromString(key)];
            [self.walletsArray addObject:wallet];
            [self.walletSelectionPopUpButton addItemWithTitle:key];
        }];
        [self.walletSelectionPopUpButton selectItemWithTitle:stringFromCurrency(self.currentCurrency)];
        [self setAccountValueLabels];
        [_httpController getTransactionsForWallet:[self walletForCurrency:self.currentCurrency] withCompletion:^(TTGoxWallet *wallet) {
            [self.accountTransactionsTableView reloadData];
        } withFailBlock:^(NSError *e) {
            RUDLog(@"Wallet History Request Failed");
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

#pragma mark buttons

-(void)marketOrderButtonPressed:(NSButton*)sender
{
    if (_limitOrderButton.state == NSOnState)
        [_limitOrderButton setState:NSOffState];
    [sender setState:NSOnState];
}

-(void)limitOrderButtonPressed:(NSButton*)sender
{
    if (_marketOrderButton.state == NSOnState)
        [_marketOrderButton setState:NSOffState];
    [sender setState:NSOnState];
}

-(void)buyActionButtonPressed:(NSButton*)sender
{
    if (_sellActionButton.state == NSOnState)
        [_sellActionButton setState:NSOffState];
    [sender setState:NSOnState];
}

-(void)sellActionButtonPressed:(NSButton*)sender
{
    if (_buyActionButton.state == NSOnState)
        [_buyActionButton setState:NSOffState];
    [sender setState:NSOnState];
}

#pragma mark nstableviewdelegate/datasource

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 20.f;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    TTLabelCellView* cellView = [tableView makeViewWithIdentifier:@"TransactionsTableView" owner:self];
    if (!cellView)
    {
        cellView = [[TTLabelCellView alloc]initWithFrame:(NSRect){0, 0, 20.f, 20.f}];
        [cellView setIdentifier:@"TransactionsTableView"];
    }
    TTGoxTransaction* transaction = [[self walletForCurrency:self.currentCurrency].transactions objectAtIndex:row];
    
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSInteger idx = [self.tableColumns indexOfObject:tableColumn];
    switch (idx) {
        case 0://Date
            [cellView setValueString:[dateFormatter stringFromDate:transaction.date]];
            break;
            
        case 1://Type
            [cellView setValueString:transaction.type];
            break;
            
        case 2://Category
            [cellView setValueString:[transaction.linkArray objectAtIndex:1]];
            break;
            
        case 3://Balance
            [cellView setValueString:[[transaction balance]display]];
            break;
        
        case 4:// Value
            [cellView setValueString:[[transaction value]display]];
            break;
            
        case 5://Acquired
            [cellView setValueString:[[[transaction trade]amount]display]];
            break;

        default:
            break;
    }
    return cellView;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self walletForCurrency:self.currentCurrency].transactions.count;
}

-(void)dealloc
{
    [_orderbook removeObserver:self forKeyPath:@"bids"];
    [_orderbook removeObserver:self forKeyPath:@"asks"];
    [_orderbook removeObserver:self forKeyPath:@"lastTicker"];
}

-(void)walletSelectionPopUpButtonDidChange:(NSPopUpButton*)sender
{
    [self setCurrentCurrency:currencyFromString(sender.selectedItem.title)];
    [_httpController getTransactionsForWallet:[self walletForCurrency:self.currentCurrency] withCompletion:^(TTGoxWallet *wallet) {
        [self.accountTransactionsTableView reloadData];
    } withFailBlock:^(NSError *e) {
        RUDLog(@"Wallet history failed");
    }];
}

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self)
    {
        [self setHttpController:[[TTGoxHTTPController alloc]init]];
        [self setCurrentCurrency:TTCurrencyUSD];
        [self reloadAccountData];
        [self setDelegate:self];
        [self setWalletsArray:[NSMutableArray array]];
        
        [self setAccountBalancesBox:[[NSBox alloc]initWithFrame:(NSRect){0, CGRectGetHeight(self.frame) - 150, CGRectGetWidth(self.frame), 100}]];
        [self.accountBalancesBox setTitlePosition:NSNoTitle];
        [self.contentView addSubview:_accountBalancesBox];
        
        [self setWalletSelectionPopUpButton:[[NSPopUpButton alloc]initWithFrame:(NSRect){20, CGRectGetHeight(self.accountBalancesBox.frame) - 40, 80, 25} pullsDown:NO]];
        [self.walletSelectionPopUpButton setAction:@selector(walletSelectionPopUpButtonDidChange:)];
        [self.walletSelectionPopUpButton setTarget:self];
        [self.accountBalancesBox.contentView addSubview:_walletSelectionPopUpButton];
        
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
        
        [self setTableColumnTitles:@[@"Date", @"Type", @"Category", @"Balance", @"Value", @"Acquired"]];
        [self setTableColumns:[NSMutableArray array]];
        
        [self.tableColumnTitles enumerateObjectsUsingBlock:^(NSString* title, NSUInteger idx, BOOL *stop) {
            NSTableColumn* tableColumn = [[NSTableColumn alloc]initWithIdentifier:title];
            [tableColumn setEditable:NO];
            if ([title isEqualToString:@"Acquired"])
                [tableColumn setWidth:120.f];
            else
                [tableColumn setWidth:60.f];
            [[tableColumn headerCell]setStringValue:title];
            [_accountTransactionsTableView addTableColumn:tableColumn];
            [self.tableColumns addObject:tableColumn];
        }];
        
        [self.accountTransactionsScrollView setDocumentView:_accountTransactionsTableView];
        [self.contentView addSubview:_accountTransactionsScrollView];
    
//        [self.accountTransactionsTableView reloadData];
        
        [self setAccountValuesReloadButton:[[NSButton alloc]initWithFrame:(NSRect){CGRectGetWidth(self.accountBalancesBox.frame) - 40, CGRectGetHeight(self.accountBalancesBox.frame) - 40, 25, 25}]];
        [self.accountValuesReloadButton setImagePosition:NSImageOnly];
        [self.accountValuesReloadButton setBordered:NO];
        
        [self.accountValuesReloadButton.cell setImageScaling:NSImageScaleProportionallyDown];
        NSImage* btnImage = [NSImage imageNamed:@"refreshIconLG.png"];
        [btnImage setSize:self.accountValuesReloadButton.frame.size];
        [self.accountValuesReloadButton setImage:btnImage];
        [self.accountBalancesBox.contentView addSubview:self.accountValuesReloadButton];
    
        [self.accountValuesReloadButton setTarget:self];
        [self.accountValuesReloadButton setAction:@selector(reloadAccountData)];

        [self setBuyActionButton:[[NSButton alloc]initWithFrame:(NSRect){20, CGRectGetMinY(self.accountTransactionsScrollView.frame) - 40, 80, 30}]];
        [_buyActionButton setButtonType:NSPushOnPushOffButton];
        [_buyActionButton setTarget:self];
        [_buyActionButton setAction:@selector(buyActionButtonPressed:)];
        [_buyActionButton setBezelStyle:NSRoundedBezelStyle];
        [_buyActionButton setTitle:@"Buy"];
        [_buyActionButton setState:NSOnState];
        [self.contentView addSubview:_buyActionButton];
    
        [self setSellActionButton:[[NSButton alloc]initWithFrame:(NSRect){CGRectGetMaxX(_buyActionButton.frame), CGRectGetMinY(self.accountTransactionsScrollView.frame) - 40, 80, 30}]];
        [_sellActionButton setButtonType:NSPushOnPushOffButton];
        [_sellActionButton setTarget:self];
        [_sellActionButton setAction:@selector(sellActionButtonPressed:)];
        [_sellActionButton setBezelStyle:NSRoundedBezelStyle];
        [_sellActionButton setTitle:@"Sell"];
        [self.contentView addSubview:_sellActionButton];
        
        [self setMarketOrderButton:[[NSButton alloc]initWithFrame:(NSRect){CGRectGetMaxX(_sellActionButton.frame) + 85, CGRectGetMinY(self.accountTransactionsScrollView.frame) - 40, 80, 30}]];
        [_marketOrderButton setButtonType:NSPushOnPushOffButton];
        [_marketOrderButton setTarget:self];
        [_marketOrderButton setAction:@selector(marketOrderButtonPressed:)];
        [_marketOrderButton setBezelStyle:NSRoundedBezelStyle];
        [_marketOrderButton setTitle:@"Market"];
        [_marketOrderButton setState:NSOnState];
        [self.contentView addSubview:_marketOrderButton];
    
        [self setLimitOrderButton:[[NSButton alloc]initWithFrame:(NSRect){CGRectGetMaxX(_marketOrderButton.frame), CGRectGetMinY(self.accountTransactionsScrollView.frame) - 40, 80, 30}]];
        [_limitOrderButton setButtonType:NSPushOnPushOffButton];
        [_limitOrderButton setTarget:self];
        [_limitOrderButton setAction:@selector(limitOrderButtonPressed:)];
        [_limitOrderButton setBezelStyle:NSRoundedBezelStyle];
        [_limitOrderButton setTitle:@"Limit"];
        [self.contentView addSubview:_limitOrderButton];
        
        [self setOrderAmountlabel:[[JNWLabel alloc]initWithFrame:(NSRect){80, CGRectGetMinY(_sellActionButton.frame) - 54, 120, 25}]];
        [_orderAmountlabel setText:@"Amount:"];
        [_orderAmountlabel setTextAlignment:NSRightTextAlignment];
        [_orderAmountlabel setFont:accountActionsFont];
        [self.contentView addSubview:_orderAmountlabel];
        
        [self setOrderPriceLabel:[[JNWLabel alloc]initWithFrame:(NSRect){80, CGRectGetMinY(_orderAmountlabel.frame) - 30, 120, 25}]];
        [_orderPriceLabel setFont:accountActionsFont];
        [_orderPriceLabel setTextAlignment:NSRightTextAlignment];
        [_orderPriceLabel setText:@"Price:"];
        [self.contentView addSubview:_orderPriceLabel];
        
        [self setOrderAmountTextField:[[NSTextField alloc]initWithFrame:(NSRect){CGRectGetMaxX(_orderAmountlabel.frame), CGRectGetMinY(_sellActionButton.frame) - 60, 120, 45}]];
        [_orderAmountTextField setAlignment:NSCenterTextAlignment];
        [_orderAmountTextField.cell setPlaceholderString:@"0 BTC"];
        [_orderAmountTextField.cell setBezelStyle:NSTextFieldRoundedBezel];
        [_orderAmountTextField setBezeled:YES];
        [_orderAmountTextField setTag:1];
        [_orderAmountTextField setDelegate:self];
        [self.contentView addSubview:_orderAmountTextField];

        [self setOrderPriceTextField:[[NSTextField alloc]initWithFrame:(NSRect){CGRectGetMaxX(_orderPriceLabel.frame), CGRectGetMinY(_orderPriceLabel.frame) + 3, 120, 25}]];
        [_orderPriceTextField setAlignment:NSCenterTextAlignment];
        [_orderPriceTextField.cell setPlaceholderString:@"$0.00"];
        [_orderPriceTextField setBezeled:YES];
        [_orderPriceTextField setTag:2];
        [_orderPriceTextField setDelegate:self];
        [_orderPriceTextField.cell setBezelStyle:NSTextFieldRoundedBezel];
        [self.contentView addSubview:_orderPriceTextField];
        
        [self setTradeExecutionButton:[[NSButton alloc]initWithFrame:(NSRect){(CGRectGetWidth(contentRect) - 278) / 2, 200, 278, 45}]];
        NSImage* excBtnImage = [NSImage imageNamed:@"tradeexecutionbtn.png"];
        [excBtnImage setSize:_tradeExecutionButton.frame.size];
        [_tradeExecutionButton setImage:excBtnImage];
        [_tradeExecutionButton setImagePosition:NSImageOnly];
        [_tradeExecutionButton setBordered:NO];
        [self.contentView addSubview:_tradeExecutionButton];
    }
    return self;
}

-(void)setOrderbook:(TTOrderBook *)orderbook
{
    [_orderbook removeObserver:self forKeyPath:@"bids"];
    [_orderbook removeObserver:self forKeyPath:@"asks"];
    [_orderbook removeObserver:self forKeyPath:@"lastTicker"];
    [self willChangeValueForKey:@"orderbook"];
    _orderbook = orderbook;
    [self didChangeValueForKey:@"orderbook"];
    [orderbook addObserver:self forKeyPath:@"bids" options:NSKeyValueObservingOptionNew context:nil];
    [orderbook addObserver:self forKeyPath:@"asks" options:NSKeyValueObservingOptionNew context:nil];
    [orderbook addObserver:self forKeyPath:@"lastTicker" options:NSKeyValueObservingOptionNew context:nil];
}

@end
