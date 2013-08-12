//
//  TTAccountWindow.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/15/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTAccountView.h"
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
#import "TTAccountBalancesBox.h"

#define feesBoxHeight 65.f

@interface TTAccountView()

@property(nonatomic, retain)TTGoxHTTPController* httpController;
@property(nonatomic, retain)NSMutableArray* walletsArray;
@property(nonatomic, retain)TTAccountBalancesBox* accountBalancesBox;
@property(nonatomic, retain)TTFeeBox* feesBox;
@property(nonatomic, retain)TTTradeExecutionBox* tradeExecutionBox;
@property(nonatomic, retain)NSScrollView* accountTransactionsScrollView;
@property(nonatomic, retain)NSTableView* accountTransactionsTableView;
@property(nonatomic, retain)NSScrollView* accountSettlementsScrollView;
@property(nonatomic, retain)NSTableView* accountSettlementsTableView;
@property(nonatomic, retain)NSArray* tableColumnTitles;
@property(nonatomic, retain)NSMutableArray* tableColumns;
@property(nonatomic, retain)NSMutableArray* settlementsTableTableColumnsArray;
@property(nonatomic, retain)NSMutableArray* settlementsArray;
@property(nonatomic, retain)NSMutableArray* settlementTableColumnsArray;
@property(nonatomic)TTCurrency currentCurrency;

@end

@implementation TTAccountView

static NSFont* accountFont;
static NSFont* accountActionsFont;

static NSDateFormatter* accountTableDateFormatter;

+(void)initialize
{
    if (self == [TTAccountView class])
    {
        accountFont = [NSFont fontWithName:@"Menlo" size:24.f];
        accountActionsFont = [NSFont fontWithName:@"Menlo" size:16.f];
        accountTableDateFormatter = [NSDateFormatter new];
    }
}

#pragma mark - C Methods

NSString* stringForTransactionType(TTGoxTransactionType type)
{
    switch (type) {
        case TTGoxTransactionTypeBitcoinPurchase:
            return @"Bought";
            break;
            
        case TTGoxTransactionTypeBitcoinSale:
            return @"Sold";
            
        case TTGoxTransactionTypeDeposit:
        case TTGoxTransactionTypeFee:
        case TTGoxTransactionTypeWithdrawal:
        case TTGoxTransactionTypeNone:
        default:
            return @"";
            break;
    }
}

NSColor* colorForTransactionType(TTGoxTransactionType type)
{
    switch (type) {
        case TTGoxTransactionTypeBitcoinPurchase:
            return [NSColor redColor];
            break;
            
        case TTGoxTransactionTypeBitcoinSale:
            return [NSColor greenColor];
            
        case TTGoxTransactionTypeDeposit:
        case TTGoxTransactionTypeFee:
        case TTGoxTransactionTypeWithdrawal:
        case TTGoxTransactionTypeNone:
        default:
            return [NSColor blackColor];
            break;
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
    NSNumberFormatter* nf = [NSNumberFormatter new];
    [nf setCurrencySymbol:@"$"];
    [nf setHasThousandSeparators:YES];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [self.accountBalancesBox.accountValueLabel setText:RUStringWithFormat(@"%@", [nf stringFromNumber:@(acctVal)])];
    [self.accountBalancesBox.primaryCurrencyLabel setText:RUStringWithFormat(@"%.5fBTC", [[[[self walletForCurrency:TTCurrencyBTC]balance]value]floatValue])];
    [self.accountBalancesBox.bitcoinCurrencyLabel setText:[nf stringFromNumber:[[[self walletForCurrency:TTCurrencyUSD]balance]value]]];
}

-(void)reloadAccountData
{
    [_httpController loadAccountDataWithCompletion:^(NSDictionary *accountInformationDictionary) {
        [self.walletsArray removeAllObjects];
        [self.accountBalancesBox.walletSelectionPopUpButton removeAllItems];
        NSDictionary* walletsDic = [accountInformationDictionary objectForKey:@"Wallets"];
        [walletsDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            TTGoxWallet* wallet = [TTGoxWallet walletFromDictionary:obj];
            [wallet setCurrency:currencyFromString(key)];
            [self.walletsArray addObject:wallet];
            [self.accountBalancesBox.walletSelectionPopUpButton addItemWithTitle:key];
        }];
        [self.accountBalancesBox.walletSelectionPopUpButton selectItemWithTitle:stringFromCurrency(self.currentCurrency)];
        [self setAccountValueLabels];
        [self.feesBox setAccountInformationToDictionary:accountInformationDictionary];
        [_httpController getTransactionsForWallet:[self walletForCurrency:self.currentCurrency] withCompletion:^(TTGoxWallet *wallet) {
            [self.accountTransactionsTableView reloadData];
            [self.feesBox setWalletForFeeDetermination:wallet];
        } withFailBlock:^(NSError *e) {
            RUDLog(@"Wallet History Request Failed");
        }];
    } andFailBlock:^(NSError *e) {
        [self.accountBalancesBox.accountValueLabel setText:RUStringWithFormat(@"--.--")];
        [self.accountBalancesBox.primaryCurrencyLabel setText:RUStringWithFormat(@"--.--")];
        [self.accountBalancesBox.bitcoinCurrencyLabel setText:RUStringWithFormat(@"--.--")];
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
            
            //@[@"Date", @"Cost/Proceed", @"Fee", @"Acquired", @"Cost Basis", @"Position Value", @"Action"]];
            
            switch (idx) {
                case 0://Date
                    [cellView setValueString:[accountTableDateFormatter stringFromDate:transaction.transactionDate]];
                    break;
                    
                case 1:
                    [cellView setValueString:stringForTransactionType(transaction.transactionType)];
                    break;
                    
                case 2://@"Cost/Proceed",
                    [cellView setValueString:RUStringWithFormat(@"$%.2f", [[transaction.transactionValue value]floatValue])];
                    break;
                    
                case 3://@"Fee"
                    [cellView setValueString:[[transaction.feePaidValue value]stringValue]];
                    break;
                    
                case 4://@"Acquired"
                    [cellView setValueString:[[transaction effectiveAcquisitionAmount]stringValue]];
                    break;
                    
                case 5:// @"Cost Basis"
                    [cellView setValueString:[[transaction costBasis]stringValue]];
                    break;
                    
                case 6:// Position Value
                    switch (transaction.transactionType) {
                        case TTGoxTransactionTypeBitcoinPurchase:
                        {
                            float posValFloat = ((transaction.effectiveAcquisitionAmount.floatValue * (self.orderbook.lastTicker.last.value.floatValue - transaction.costBasis.floatValue)) - transaction.feePaidValue.value.floatValue);
                            [cellView setValueString:RUStringWithFormat(@"$%.2f", posValFloat)];
                            break;
                        }
                        case TTGoxTransactionTypeBitcoinSale:
                        {
                            float posValFloat = ((transaction.effectiveAcquisitionAmount.floatValue * (self.orderbook.lastTicker.last.value.floatValue - transaction.costBasis.floatValue)) - transaction.feePaidValue.value.floatValue);
                            [cellView setValueString:RUStringWithFormat(@"$%.2f", posValFloat)];
                            break;
                        }
                        default:
                            break;
                    }
                    break;
                    
                case 7:
                    [cellView setValueString:@""];
                    
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
        RUDLog(@"%@", [wallet.transactions objectAtIndex:0]);
        [self.accountTransactionsTableView reloadData];
        [self.feesBox setWalletForFeeDetermination:wallet];
    } withFailBlock:^(NSError *e) {
        RUDLog(@"Wallet history failed");
    }];
}

-(id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        [self setHttpController:[[TTGoxHTTPController alloc]init]];
        [self setCurrentCurrency:TTCurrencyUSD];
        [self setSettlementsArray:[NSMutableArray array]];
        [self reloadAccountData];
        [self setWalletsArray:[NSMutableArray array]];
        
        [self setAccountBalancesBox:[[TTAccountBalancesBox alloc]initWithFrame:NSZeroRect]];
        [self.accountBalancesBox setTitlePosition:NSNoTitle];
        [self addSubview:_accountBalancesBox];
        
        [self.accountBalancesBox.fastBuyButton setTarget:self];
        [self.accountBalancesBox.fastBuyButton setAction:@selector(fastBuy:)];
        
        [self.accountBalancesBox.fastSellButton setTarget:self];
        [self.accountBalancesBox.fastSellButton setAction:@selector(fastSell:)];
        
        [self.accountBalancesBox.accountValuesReloadButton setTarget:self];
        [self.accountBalancesBox.accountValuesReloadButton setAction:@selector(reloadAccountData)];
        
        [self.accountBalancesBox.walletSelectionPopUpButton setAction:@selector(walletSelectionPopUpButtonDidChange:)];
        [self.accountBalancesBox.walletSelectionPopUpButton setTarget:self];
        
        [self setAccountTransactionsScrollView:[[NSScrollView alloc]initWithFrame:NSZeroRect]];
        [self.accountTransactionsScrollView setHasVerticalScroller:YES];
        [self.accountTransactionsScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        [self setAccountTransactionsTableView:[[NSTableView alloc]initWithFrame:NSZeroRect]];
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
        
        [self setTableColumnTitles:@[@"Date", @"Type", @"Proceed", @"Fee", @"Acquired", @"Cost Basis", @"Position Value", @"Action"]];
        NSArray* columnWidthsArray = @[@(80), @(50), @(80), @(80), @(130), @(130), @(130), @(130)];
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
        [self addSubview:_accountTransactionsScrollView];
                
        [self setTradeExecutionBox:[[TTTradeExecutionBox alloc]initWithFrame:NSZeroRect]];
        [_tradeExecutionBox setTitlePosition:NSNoTitle];
        [_tradeExecutionBox setHttpController:self.httpController];
        [self addSubview:_tradeExecutionBox];
        
        [self setFeesBox:[[TTFeeBox alloc]initWithFrame:NSZeroRect]];
        [self.feesBox setTitlePosition:NSNoTitle];
        [self addSubview:_feesBox];
        
        [self setAccountSettlementsScrollView:[[NSScrollView alloc]initWithFrame:NSZeroRect]];
        [_accountSettlementsScrollView setHasVerticalScroller:YES];
        [_accountSettlementsScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        [self setAccountSettlementsTableView:[[NSTableView alloc]initWithFrame:NSZeroRect]];
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
        
        [self setSettlementsTableTableColumnsArray:[NSMutableArray array]];
        
        NSTableColumn* settlementsColum = [[NSTableColumn alloc]initWithIdentifier:@"Settlements"];
        [settlementsColum setEditable:NO];
        [[settlementsColum headerCell]setStringValue:@"Settlements"];
        [self.settlementTableColumnsArray addObject:settlementsColum];
        [_accountSettlementsTableView addTableColumn:settlementsColum];
        
        [_accountSettlementsScrollView setDocumentView:_accountSettlementsTableView];
        [self addSubview:_accountSettlementsScrollView];
        
        [_accountSettlementsTableView reloadData];
        
        [self setFrame:frameRect];
    }
    return self;
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [self.accountBalancesBox setFrame:(NSRect){0, CGRectGetHeight(self.frame) - 100, CGRectGetWidth(self.frame), 100}];
    [_feesBox setFrame:(NSRect){0, CGRectGetMinY(self.accountBalancesBox.frame) - feesBoxHeight, CGRectGetWidth(self.frame), feesBoxHeight}];
    [self.accountTransactionsScrollView setFrame:(NSRect){0, CGRectGetMinY(_feesBox.frame) - 200, CGRectGetWidth(self.frame), 200}];
    [self.accountTransactionsTableView setFrame:(NSRect){0, 0, CGRectGetWidth(self.frame), 150}];
    [_tradeExecutionBox setFrame:(NSRect){0, CGRectGetMinY(self.accountTransactionsScrollView.frame) - 200, CGRectGetWidth(self.frame), 200}];
    [_accountSettlementsScrollView setFrame:(NSRect){0, CGRectGetMinY(_tradeExecutionBox.frame) - 100, CGRectGetWidth(self.frame), 100}];
    [_accountSettlementsTableView setFrame:(NSRect){0, 0, CGRectGetWidth(self.frame), 200}];
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
