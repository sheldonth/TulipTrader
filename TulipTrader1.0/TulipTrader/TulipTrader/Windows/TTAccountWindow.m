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
#import "TTFeeBox.h"
#import "TTTradeExecutionBox.h"
#import "RUClassOrNilUtil.h"

//#define primaryCurrency @"USD"

#define feesBoxHeight 65.f

@interface TTAccountWindow()

@property(nonatomic, retain)TTGoxHTTPController* httpController;
@property(nonatomic, retain)JNWLabel* accountValueLabel;
@property(nonatomic, retain)JNWLabel* primaryCurrencyLabel;
@property(nonatomic, retain)JNWLabel* bitcoinCurrencyLabel;

@property(nonatomic, retain)NSMutableArray* walletsArray;

@property(nonatomic, retain)NSBox* accountBalancesBox;

@property(nonatomic, retain)TTFeeBox* feesBox;

@property(nonatomic, retain)TTTradeExecutionBox* tradeExecutionBox;

@property(nonatomic, retain)NSPopUpButton* walletSelectionPopUpButton;

@property(nonatomic, retain)NSScrollView* accountTransactionsScrollView;
@property(nonatomic, retain)NSTableView* accountTransactionsTableView;

@property(nonatomic, retain)NSScrollView* accountSettlementsScrollView;
@property(nonatomic, retain)NSTableView* accountSettlementsTableView;

@property(nonatomic, retain)NSArray* tableColumnTitles;
@property(nonatomic, retain)NSMutableArray* tableColumns;

@property(nonatomic, retain)NSMutableArray* settlementsTableTableColumnsArray;

@property(nonatomic, retain)NSButton* accountValuesReloadButton;

@property(nonatomic, retain)NSButton* fastBuyButton;
@property(nonatomic, retain)NSButton* fastSellButton;

@property(nonatomic, retain)NSMutableArray* settlementsArray;

@property(nonatomic)TTCurrency currentCurrency;

@end

@implementation TTAccountWindow

static NSFont* accountFont;
static NSFont* accountActionsFont;

static NSDateFormatter* accountTableDateFormatter;

+(void)initialize
{
    if (self == [TTAccountWindow class])
    {
        accountFont = [NSFont fontWithName:@"Menlo" size:24.f];
        accountActionsFont = [NSFont fontWithName:@"Menlo" size:16.f];
        accountTableDateFormatter = [NSDateFormatter new];
    }
}

#pragma mark - TTOrderBookAccountEventDelegate methods

-(void)settlementEventObserved:(NSDictionary *)eventData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.settlementsArray insertObject:eventData atIndex:0];
        [self.accountSettlementsTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationSlideLeft];
    });
}

-(void)walletStateObserved:(NSDictionary *)walletDataDictionary
{
    TTGoxWallet* w = [self walletForCurrency:currencyFromString([[walletDataDictionary objectForKey:@"balance"]objectForKey:@"currency"])];
    [w setBalance:[TTTick newTickfromDictionary:[walletDataDictionary objectForKey:@"balance"]]];
    [self setAccountValueLabels];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"bids"])
    {
        [self.tradeExecutionBox setBidArray:[change objectForKey:@"new"]];
    }
    else if ([keyPath isEqualToString:@"asks"])
    {
        [self.tradeExecutionBox setAskArray:[change objectForKey:@"new"]];
    }
    else if ([keyPath isEqualToString:@"lastTicker"])
    {
        [self setAccountValueLabels];
        [self.feesBox setLastTicker:self.orderbook.lastTicker];
    }
}

-(void)fastBuy:(id)sender
{
    [_httpController placeOrder:TTAccountWindowExecutionStateBuying amountInteger:100000000 placementType:TTAccountWindowExecutionTypeMarket priceInteger:0 withCompletion:^(BOOL success, NSDictionary *callbackData) {
        
    } withFailBlock:^(NSError *error) {
        
    }];
}

-(void)fastSell:(id)sender
{
    [_httpController placeOrder:TTAccountWindowExecutionStateSelling amountInteger:100000000 placementType:TTAccountWindowExecutionTypeMarket priceInteger:0 withCompletion:^(BOOL success, NSDictionary *callbackData) {
        
    } withFailBlock:^(NSError *error) {
        
    }];
}

-(void)setupLabels
{
    if (!_accountValueLabel)
    {
        [self setAccountValueLabel:[[JNWLabel alloc]initWithFrame:(NSRect){0, CGRectGetHeight(self.accountBalancesBox.frame) - 40, CGRectGetWidth(self.frame), 25}]];
        [self.accountValueLabel setFont:accountFont];
        [self.accountValueLabel setTextAlignment:NSCenterTextAlignment];
        [self.accountValueLabel setAutoresizingMask:(NSViewMinXMargin | NSViewMaxXMargin)];
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
        [_fastBuyButton setTarget:self];
        [_fastBuyButton setAction:@selector(fastBuy:)];
        NSImage* icn = [NSImage imageNamed:@"arrow_left.png"];
        [icn setSize:_fastBuyButton.frame.size];
        [_fastBuyButton setImage:icn];
        [self.accountBalancesBox.contentView addSubview:_fastBuyButton];
    }
    if (!self.fastSellButton)
    {
        [self setFastSellButton:[[NSButton alloc]initWithFrame:(NSRect){CGRectGetWidth([self.accountBalancesBox.contentView frame]) - 25, 5, 20, 35}]];
        [_fastSellButton setTarget:self];
        [_fastSellButton setAction:@selector(fastSell:)];
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
        [self.feesBox setAccountInformationToDictionary:accountInformationDictionary];
        [_httpController getTransactionsForWallet:[self walletForCurrency:self.currentCurrency] withCompletion:^(TTGoxWallet *wallet) {
            [self.accountTransactionsTableView reloadData];
            [self.feesBox setWalletForFeeDetermination:wallet];
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

#pragma mark nstableviewdelegate/datasource

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    switch (tableView.tag) {
        case 1:
            return 20.f;
            break;
            
        case 2:
            return 20.f;
            break;
            
        default:
            return 0.f;
            break;
    }
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    switch (tableView.tag) {
        case 1:
        {
            TTLabelCellView* cellView = [tableView makeViewWithIdentifier:@"TransactionsTableView" owner:self];
            if (!cellView)
            {
                cellView = [[TTLabelCellView alloc]initWithFrame:(NSRect){0, 0, 20.f, 20.f}];
                [cellView setIdentifier:@"TransactionsTableView"];
            }
            TTGoxTransaction* transaction = [[self walletForCurrency:self.currentCurrency].transactions objectAtIndex:row];
            
            
            [accountTableDateFormatter setDateStyle:NSDateFormatterShortStyle];
            NSInteger idx = [self.tableColumns indexOfObject:tableColumn];
            switch (idx) {
                case 0://Date
                    [cellView setValueString:[accountTableDateFormatter stringFromDate:transaction.date]];
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
            break;
        }
        case 2:
        {
            TTLabelCellView* cellView = [tableView makeViewWithIdentifier:@"SettlementsTableView" owner:self];
            if (!cellView)
            {
                cellView = [[TTLabelCellView alloc]initWithFrame:(NSRect){0.f, 0.f, 20.f, CGRectGetWidth(tableView.frame)}];
                [cellView setIdentifier:@"SettlementsTableView"];
            }
            NSDictionary* settlementDict = [self.settlementsArray objectAtIndex:row];
            NSString* type = [settlementDict objectForKey:@"type"];
            TTTick* amountTick = [TTTick newTickfromDictionary:[settlementDict objectForKey:@"amount"]];
            NSString* status = [settlementDict objectForKey:@"status"];
            if (type)
                [cellView setValueString:RUStringWithFormat(@"%@ for %@ is %@", type, amountTick.display_short, status)];
            else
                [cellView setValueString:RUStringWithFormat(@"%@ %@", [settlementDict objectForKey:@"oid"], [settlementDict objectForKey:@"reason"]]);
            return cellView;
        }
            
        default:
        {
            return nil;
            break;
        }
    }
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    switch (tableView.tag) {
        case 1:
            return [self walletForCurrency:self.currentCurrency].transactions.count;
            break;
            
        case 2:
            return self.settlementsArray.count;
            break;
            
        default:
            return 0;
            break;
    }
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
        [self.feesBox setWalletForFeeDetermination:wallet];
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
        [self setSettlementsArray:[NSMutableArray array]];
        [self reloadAccountData];
        [self setDelegate:self];
        [self setWalletsArray:[NSMutableArray array]];
        
        [self setAccountBalancesBox:[[NSBox alloc]initWithFrame:(NSRect){0, CGRectGetHeight(self.frame) - 150, CGRectGetWidth(self.frame), 100}]];
        [self.accountBalancesBox setTitlePosition:NSNoTitle];
        [self.accountBalancesBox setAutoresizingMask:(NSViewWidthSizable)];
        [self.contentView addSubview:_accountBalancesBox];
        
        [self setWalletSelectionPopUpButton:[[NSPopUpButton alloc]initWithFrame:(NSRect){20, CGRectGetHeight(self.accountBalancesBox.frame) - 40, 80, 25} pullsDown:NO]];
        [self.walletSelectionPopUpButton setAction:@selector(walletSelectionPopUpButtonDidChange:)];
        [self.walletSelectionPopUpButton setTarget:self];
        [self.accountBalancesBox.contentView addSubview:_walletSelectionPopUpButton];
        
        [self setAccountTransactionsScrollView:[[NSScrollView alloc]initWithFrame:(NSRect){0, CGRectGetMinY(_accountBalancesBox.frame) - (185 + feesBoxHeight), CGRectGetWidth(self.frame), 200}]];
        [self.accountTransactionsScrollView setHasVerticalScroller:YES];
        [self.accountTransactionsScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        [self setAccountTransactionsTableView:[[NSTableView alloc]initWithFrame:(NSRect){0, 0, CGRectGetWidth(self.frame), 150}]];
        [_accountTransactionsTableView setDataSource:self];
        [_accountTransactionsTableView setTag:1];
        [_accountTransactionsTableView setDelegate:self];
        [_accountTransactionsTableView setUsesAlternatingRowBackgroundColors:YES];
        [_accountTransactionsTableView setGridStyleMask:(NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask)];
        [_accountTransactionsTableView setAllowsColumnReordering:YES];
        [_accountTransactionsTableView setAllowsColumnResizing:YES];
        [_accountTransactionsTableView setAllowsExpansionToolTips:YES];
        [_accountTransactionsTableView setAllowsMultipleSelection:YES];
        [_accountTransactionsTableView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        [self setTableColumnTitles:@[@"Date", @"Type", @"Category", @"Balance", @"Value", @"Acquired"]];
        NSArray* columnWidthsArray = @[@(80), @(50), @(80), @(80), @(130), @(130)];
        [self setTableColumns:[NSMutableArray array]];
        
        [self.tableColumnTitles enumerateObjectsUsingBlock:^(NSString* title, NSUInteger idx, BOOL *stop) {
            NSTableColumn* tableColumn = [[NSTableColumn alloc]initWithIdentifier:title];
            [tableColumn setEditable:NO];
            [tableColumn setWidth:[(NSNumber*)[columnWidthsArray objectAtIndex:idx]floatValue]];
            [[tableColumn headerCell]setStringValue:title];
            [_accountTransactionsTableView addTableColumn:tableColumn];
            [self.tableColumns addObject:tableColumn];
        }];
        
        [self.accountTransactionsScrollView setDocumentView:_accountTransactionsTableView];
        [self.contentView addSubview:_accountTransactionsScrollView];
        
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
        
        [self setTradeExecutionBox:[[TTTradeExecutionBox alloc]initWithFrame:(NSRect){0, CGRectGetMinY(self.accountTransactionsScrollView.frame) - 200, CGRectGetWidth(self.frame), 200}]];
        [_tradeExecutionBox setTitlePosition:NSNoTitle];
        [_tradeExecutionBox setHttpController:self.httpController];
        [self.contentView addSubview:_tradeExecutionBox];
        
        [self setFeesBox:[[TTFeeBox alloc]initWithFrame:(NSRect){0, CGRectGetMinY(self.accountBalancesBox.frame) - feesBoxHeight, CGRectGetWidth(self.frame), feesBoxHeight}]];
        [self.feesBox setTitlePosition:NSNoTitle];
        [self.contentView addSubview:_feesBox];
        
        [self setAccountSettlementsScrollView:[[NSScrollView alloc]initWithFrame:(NSRect){0, CGRectGetMinY(_tradeExecutionBox.frame) - 80, CGRectGetWidth(self.frame), 100}]];
        [_accountSettlementsScrollView setHasVerticalScroller:YES];
        [_accountSettlementsScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        [self setAccountSettlementsTableView:[[NSTableView alloc]initWithFrame:(NSRect){0, 0, CGRectGetWidth(self.frame), 150}]];
        [_accountSettlementsTableView setDataSource:self];
        [_accountSettlementsTableView setTag:2];
        [_accountSettlementsTableView setDelegate:self];
        [_accountSettlementsTableView setUsesAlternatingRowBackgroundColors:YES];
        [_accountSettlementsTableView setGridStyleMask:(NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask)];
        [_accountSettlementsTableView setAllowsColumnReordering:YES];
        [_accountSettlementsTableView setAllowsColumnResizing:YES];
        [_accountSettlementsTableView setAllowsExpansionToolTips:YES];
        [_accountSettlementsTableView setAllowsMultipleSelection:YES];
        [_accountSettlementsTableView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        NSTableColumn* settlementsColum = [[NSTableColumn alloc]initWithIdentifier:@"Settlements"];
        [settlementsColum setEditable:NO];
        [settlementsColum setWidth:_accountSettlementsScrollView.frame.size.width];
        [[settlementsColum headerCell]setStringValue:@"Settlements"];
        [_accountSettlementsTableView addTableColumn:settlementsColum];
        
        [_accountSettlementsScrollView setDocumentView:_accountSettlementsTableView];
        [self.contentView addSubview:_accountSettlementsScrollView];
        
        [_accountSettlementsTableView reloadData];
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
    [_orderbook setAccountEventDelegate:self];
    [self didChangeValueForKey:@"orderbook"];
    [orderbook addObserver:self forKeyPath:@"bids" options:NSKeyValueObservingOptionNew context:nil];
    [orderbook addObserver:self forKeyPath:@"asks" options:NSKeyValueObservingOptionNew context:nil];
    [orderbook addObserver:self forKeyPath:@"lastTicker" options:NSKeyValueObservingOptionNew context:nil];
}

@end
