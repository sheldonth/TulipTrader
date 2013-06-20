//
//  TTAccountBox.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/30/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTAccountBox.h"
#import "TTGoxHTTPController.h"
#import "RUConstants.h"
#import "TTTextView.h"
#import "TTGoxAccount.h"
#import "TTGoxWallet.h"
#import "Order.h"
#import "TTTextPaneScrollView.h"
#import "JNWLabel.h"
#import "AFURLConnectionOperation.h"
#import "TTAPIControlBoxView.h"
#import "TTTransactionBox.h"
#import "Transaction.h"

@interface TTAccountBox()

@property(nonatomic, retain)TTGoxHTTPController* httpController;

@property(nonatomic, retain)TTTextPaneScrollView* accountDataTextPane;
@property(nonatomic, retain)TTTextPaneScrollView* tradeDataTextPane;

@property(nonatomic, retain)JNWLabel* ordersLabel;

@property(nonatomic, retain)NSTimer* accountDataTimer;
@property(nonatomic, retain)NSTimer* ordersDataTimer;

@property(nonatomic, retain)NSPopUpButton* walletSelectionPopUpButton;

@property(nonatomic, retain)NSScrollView* transactionsScrollView;
@property(nonatomic, retain)JNWLabel* selectWalletLabel;

@property(nonatomic, retain)NSMutableArray* transactionBoxes;

@property(nonatomic, retain)NSProgressIndicator* walletTransactionsProgressIndicator;


@end

@implementation TTAccountBox

static NSDateFormatter* dateFormatter;

#define kTTPopUpSelectorNoItemString @"****"
#define kTTTransactionBoxHeight 120.f

+(void)initialize
{
    dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
}

-(void)loadSequential
{
    [self getAccountDataWithCompletion:^{
        [self getOrderData];
    }];
}

NSString* accountToString(TTGoxAccount* account)
{
    NSMutableString* outputStr = [NSMutableString string];
    [outputStr appendFormat:@"Username: %@\n", account.username];
    [outputStr appendFormat:@"Last Login: %@\n", [dateFormatter stringFromDate:account.loginDate]];
    [outputStr appendFormat:@"Monthly Volume: %@\n", account.monthlyVolume.display_short];
    if (account.permissionsArray.count == 5)
        [outputStr appendString:@"Rights : All"];
    else
    {
        [outputStr appendFormat:@"Rights: "];
        for (NSString* s in account.permissionsArray) {
            [outputStr appendFormat:@"%@ ", s];
        }
    }
    [outputStr appendFormat:@"\nCurrent Trade Fee: %@%%", account.tradeFee.stringValue];
    [account.currencyWallets enumerateObjectsUsingBlock:^(TTGoxWallet* obj, NSUInteger idx, BOOL *stop) {
        [outputStr appendFormat:@"\n%@ Wallet: %@ Operations\n\tBalance: %.2f\n\tDaily %.2f\n\tMonthly %.2f\n\tMax %.2f\n\tOpen %@", stringFromCurrency(obj.currency), obj.operationCount.stringValue, obj.balance.value.floatValue, obj.dailyWithdrawalLimit.value.floatValue, obj.monthlyWithdrawLimit.value.floatValue, obj.maxWithdraw.value.floatValue, obj.openOrders.display];
    }];
    return outputStr;
}

NSString* ordersArrayToString(NSArray* ordersArray)
{
    NSPredicate* bidPredicate = [NSPredicate predicateWithFormat:@"orderType == %u", TTGoxOrderTypeBid];
    NSArray* bidOrders = [ordersArray filteredArrayUsingPredicate:bidPredicate];
    
    NSPredicate* askPredicate = [NSPredicate predicateWithFormat:@"orderType == %u", TTGoxOrderTypeAsk];
    NSArray* askOrders = [ordersArray filteredArrayUsingPredicate:askPredicate];
    
    NSSortDescriptor* dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    
    NSSortDescriptor* currencySortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"currency" ascending:YES];
    
    NSArray* sortedBidOrders = [bidOrders sortedArrayUsingDescriptors:@[currencySortDescriptor, dateSortDescriptor]];
    NSArray* sortedAskOrders = [askOrders sortedArrayUsingDescriptors:@[currencySortDescriptor, dateSortDescriptor]];
    
    NSMutableString* s = [NSMutableString string];
    [s appendString:@"BIDS:\n"];
    [sortedBidOrders enumerateObjectsUsingBlock:^(Order* obj, NSUInteger idx, BOOL *stop) {
        [s appendFormat:@"\t%@ %@ BUY %@ AT %@\n", stringFromOrderStatus(obj.orderStatus), stringFromCurrency(obj.currency), obj.amount.display, obj.price.display];
    }];
    
    [s appendString:@"ASKS:\n"];
    
    [sortedAskOrders enumerateObjectsUsingBlock:^(Order* obj, NSUInteger idx, BOOL *stop) {
        [s appendFormat:@"\t%@ %@ SELL %@ AT %@\n", stringFromOrderStatus(obj.orderStatus), stringFromCurrency(obj.currency), obj.amount.display, obj.price.display];
    }];
    
    [s appendString:@"\n\n\nREMINDER:\n•Spreads are 1 pip(point in percentage) or .00001\n•This market quotes exchange rates to >= 5 decimal places\n•1000pips = $.01 or a penny of the counter currency"];
    
    return s;
}

-(void)walletButtonDidSelect:(NSPopUpButton*)sender
{
    if ([sender.selectedItem.title isEqualToString:kTTPopUpSelectorNoItemString])
        return;
    if ([sender indexOfItemWithTitle:kTTPopUpSelectorNoItemString] >= 0)
        [sender removeItemWithTitle:kTTPopUpSelectorNoItemString];
    TTGoxCurrency c = currencyFromString(sender.selectedItem.title);
    NSInteger index = [self.account.currencyWallets indexOfObjectPassingTest:^BOOL(TTGoxWallet* obj, NSUInteger idx, BOOL *stop) {
        if (obj.currency == c)
            return YES;
        else
            return NO;
    }];
    TTGoxWallet* selectedWallet = [self.account.currencyWallets objectAtIndex:index];
    [self getTransactionHistoryForWallet:selectedWallet];
}

-(void)getTransactionHistoryForWallet:(TTGoxWallet*)wallet
{
    [self.walletTransactionsProgressIndicator startAnimation:self];
    [self.transactionBoxes enumerateObjectsUsingBlock:^(TTTransactionBox* obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
        [(NSView*)self.transactionsScrollView.documentView setFrame:(NSRect){0,0,CGRectGetWidth(self.transactionsScrollView.frame), CGRectGetHeight(self.transactionsScrollView.frame)}];
    }];
    [_httpController getTransactionsForWallet:wallet withCompletion:^(TTGoxWallet *wallet) {
        CGFloat proposedSize = wallet.transactions.count * kTTTransactionBoxHeight;
        if (proposedSize > [(NSView*)self.transactionsScrollView.documentView frame].size.height)
            [(NSView*)self.transactionsScrollView.documentView setFrame:(NSRect){0,0,self.transactionsScrollView.frame.size.width, proposedSize}];
        [wallet.transactions enumerateObjectsUsingBlock:^(Transaction* obj, NSUInteger idx, BOOL *stop) {
            TTTransactionBox* transactionBox = [[TTTransactionBox alloc]initWithFrame:(NSRect){0, CGRectGetHeight([(NSView*)self.transactionsScrollView.documentView frame]) - ((idx + 1) * kTTTransactionBoxHeight), CGRectGetWidth(self.transactionsScrollView.frame), kTTTransactionBoxHeight}];
            [(NSView*)self.transactionsScrollView.documentView addSubview:transactionBox];
            [transactionBox setTransaction:obj];
            [self.transactionBoxes addObject:transactionBox];
        }];
        NSPoint pt = NSMakePoint(0.0, [[self.transactionsScrollView documentView]
                                       bounds].size.height);
        [[self.transactionsScrollView documentView] scrollPoint:pt];
        [self.walletTransactionsProgressIndicator stopAnimation:self];
    } withFailBlock:^(NSError *e) {
        [self.walletTransactionsProgressIndicator stopAnimation:self];
    }];
}

-(void)getOrderData
{
    if (self.ordersDataTimer)
        [self.ordersDataTimer invalidate];
    [_httpController getOrdersWithCompletion:^(NSArray *orders) {
        [self setOrders:orders];
        [self.tradeDataTextPane.textView setString:ordersArrayToString(orders)];
    } withFailBlock:^(NSError *e) {
        NSURLRequest* failingRequest = [[e userInfo]objectForKey:AFNetworkingOperationFailingURLRequestErrorKey];
        NSHTTPURLResponse* failingResponse =  [[e userInfo]objectForKey:AFNetworkingOperationFailingURLResponseErrorKey];
        [self.tradeDataTextPane.textView setString:RUStringWithFormat(@"%@ Failed %ld\nRetrying in 3 seconds or run 'orders'", failingRequest.URL.absoluteString, failingResponse.statusCode)];
        [TTAPIControlBoxView publishCommand:@"Orders Data Failed" repeating:YES];
        [self setOrdersDataTimer:[NSTimer scheduledTimerWithTimeInterval:3.f target:self selector:@selector(getOrderData) userInfo:nil repeats:NO]];
    }];
}

-(void)getAccountData
{
    [self getAccountDataWithCompletion:nil];
}

-(void)getAccountDataWithCompletion:(void (^)())completion
{
    if (self.accountDataTimer)
        [self.accountDataTimer invalidate];
    [_httpController loadAccountDataWithCompletion:^(NSDictionary* accountInformation) {
        [self setAccount:accountFromDictionary(accountInformation)];
        [self.accountDataTextPane.textView setString:accountToString(self.account)];
        [self.account.currencyWallets enumerateObjectsUsingBlock:^(TTGoxWallet* obj, NSUInteger idx, BOOL *stop) {
            [self.walletSelectionPopUpButton addItemWithTitle:stringFromCurrency(obj.currency)];
        if (completion)
            completion();
        }];
    } andFailBlock:^(NSError *e) {
        NSURLRequest* failingRequest = [[e userInfo]objectForKey:AFNetworkingOperationFailingURLRequestErrorKey];
        NSHTTPURLResponse* failingResponse =  [[e userInfo]objectForKey:AFNetworkingOperationFailingURLResponseErrorKey];
        [self.accountDataTextPane.textView setString:RUStringWithFormat(@"%@ Failed %ld\n Retrying in 3 seconds or run 'account'", failingRequest.URL.absoluteString, failingResponse.statusCode)];
        [TTAPIControlBoxView publishCommand:@"Account Data Failed" repeating:YES];
        [self setAccountDataTimer:[NSTimer scheduledTimerWithTimeInterval:3.f target:self selector:@selector(getAccountData) userInfo:nil repeats:NO]];
    }];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBorderWidth:2.f];
        [self setBorderColor:[NSColor blackColor]];
        [self setTitle:@"Account\t\t\t\t\t\t\t\tOrders"];
        [self setTransactionBoxes:[NSMutableArray array]];
        [self setHttpController:[TTGoxHTTPController sharedInstance]];
    }
    return self;
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    NSRect contentFrame = [(NSView*)self.contentView frame];
    CGFloat accountStatsColumnWidth = floorf(CGRectGetWidth(contentFrame) / 4);
    CGFloat positionAccountHistoryColumnWidth = floorf((CGRectGetWidth(contentFrame) - accountStatsColumnWidth) / 2);
    NSRect f = (NSRect){0, 0, accountStatsColumnWidth, CGRectGetHeight(contentFrame)};
    if (!self.accountDataTextPane)
    {
        [self setAccountDataTextPane:[[TTTextPaneScrollView alloc]initWithFrame:f]];
        [self.contentView addSubview:self.accountDataTextPane];
        [self.accountDataTextPane.textView setString:@"Loading..."];
    }
    if (!self.tradeDataTextPane)
    {
        [self setTradeDataTextPane:[[TTTextPaneScrollView alloc]initWithFrame:(NSRect){_accountDataTextPane.frame.size.width, 0, positionAccountHistoryColumnWidth, CGRectGetHeight(contentFrame)}]];
        [self.contentView addSubview:self.tradeDataTextPane];
        [self.tradeDataTextPane.textView setString:@"Loading..."];
    }
    if (!self.ordersLabel)
    {
        [self setOrdersLabel:[[JNWLabel alloc]initWithFrame:(NSRect){_accountDataTextPane.frame.size.width, CGRectGetHeight(frameRect) - 30, 60, 30}]];
        [_ordersLabel setText:@"Orders"];
        [_ordersLabel setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
//        [self addSubview:_ordersLabel];
    }
    if (!self.transactionsScrollView)
    {
        [self setTransactionsScrollView:[[NSScrollView alloc]initWithFrame:(NSRect){CGRectGetMaxX(self.tradeDataTextPane.frame), 0, CGRectGetWidth(self.tradeDataTextPane.frame), CGRectGetHeight(frameRect) - 50}]];
        [_transactionsScrollView setDocumentView:[[NSView alloc]initWithFrame:(NSRect){0, 0, CGRectGetWidth(self.transactionsScrollView.frame), CGRectGetHeight(self.transactionsScrollView.frame)}]];
        [_transactionsScrollView setHasVerticalScroller:YES];
        [_transactionsScrollView setHasHorizontalScroller:NO];
        [_transactionsScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [_transactionsScrollView setDrawsBackground:NO];
        [self.contentView addSubview:self.transactionsScrollView];
    }
    if (!self.walletSelectionPopUpButton)
    {
        [self setWalletSelectionPopUpButton:[[NSPopUpButton alloc]initWithFrame:(NSRect){CGRectGetMidX(self.transactionsScrollView.frame), CGRectGetHeight(self.transactionsScrollView.frame), 80, 25} pullsDown:NO]];
        [self.walletSelectionPopUpButton addItemWithTitle:kTTPopUpSelectorNoItemString];
        [self.walletSelectionPopUpButton setAction:@selector(walletButtonDidSelect:)];
        [self.walletSelectionPopUpButton setTarget:self];
        [self.contentView addSubview:_walletSelectionPopUpButton];
    }
    if (!self.selectWalletLabel)
    {
        [self setSelectWalletLabel:[[JNWLabel alloc]initWithFrame:(NSRect){CGRectGetMidX(self.transactionsScrollView.frame) - 120, CGRectGetHeight(self.transactionsScrollView.frame), 120, 20}]];
        [_selectWalletLabel setText:@"Select Wallet:"];
        [_selectWalletLabel setTextAlignment:NSRightTextAlignment];
        [self.contentView addSubview:_selectWalletLabel];
    }
    if (!self.walletTransactionsProgressIndicator)
    {
        [self setWalletTransactionsProgressIndicator:[[NSProgressIndicator alloc]initWithFrame:(NSRect){CGRectGetMaxX(_walletSelectionPopUpButton.frame), _walletSelectionPopUpButton.frame.origin.y, 25, 25}]];
        [_walletTransactionsProgressIndicator setStyle:(NSProgressIndicatorSpinningStyle)];
        [_walletTransactionsProgressIndicator setDisplayedWhenStopped:NO];
        [self.contentView addSubview:_walletTransactionsProgressIndicator];
    }
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
//    [[NSColor orangeColor] setFill];
//    NSRectFill(dirtyRect);
}

@end
