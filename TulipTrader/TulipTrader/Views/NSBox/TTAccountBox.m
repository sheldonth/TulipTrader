//
//  TTAccountBox.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/30/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTAccountBox.h"
#import "TTGoxHTTPController.h"
#import "RUConstants.h"
#import "TTTextView.h"
#import "TTGoxAccount.h"
#import "TTGoxWallet.h"
#import "Order.h"

@interface TTAccountBox()

@property(nonatomic, retain)TTGoxHTTPController* httpController;
@property(nonatomic, retain)TTTextView* accountDataTextView;
@property(nonatomic, retain)NSScrollView* accountDataScrollView;

@property(nonatomic, retain)TTTextView* tradeDataTextView;
@property(nonatomic, retain)NSScrollView* tradeDataScrollView;

@end

@implementation TTAccountBox

static NSDateFormatter* dateFormatter;

+(void)initialize
{
    dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
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
        [outputStr appendFormat:@"\n%@ Wallet: %@ Operations\n\tBalance: %@\n\tDaily %@\n\tMonthly %@\n\tMax %@\n\tOpen %@", stringFromCurrency(obj.currency), obj.operationCount.stringValue, obj.balance.display, obj.dailyWithdrawalLimit.display, obj.monthlyWithdrawLimit.display, obj.maxWithdraw.display, obj.openOrders.display];
    }];
    return outputStr;
}

NSString* ordersArrayToString(NSArray* ordersArray)
{
//    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"orderType" ascending:YES];
    NSPredicate* bidPredicate = [NSPredicate predicateWithFormat:@"orderType == %u", TTGoxOrderTypeBid];
    NSArray* bidOrders = [ordersArray filteredArrayUsingPredicate:bidPredicate];
    
    NSPredicate* askPredicate = [NSPredicate predicateWithFormat:@"orderType == %u", TTGoxOrderTypeAsk];
    NSArray* askOrders = [ordersArray filteredArrayUsingPredicate:askPredicate];
    
    NSSortDescriptor* dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    NSArray* sortedBidOrders = [bidOrders sortedArrayUsingDescriptors:@[dateSortDescriptor]];
    NSArray* sortedAskOrders = [askOrders sortedArrayUsingDescriptors:@[dateSortDescriptor]];
    
    NSMutableString* s = [NSMutableString string];
    [s appendString:@"BIDS:\n"];
    [sortedBidOrders enumerateObjectsUsingBlock:^(Order* obj, NSUInteger idx, BOOL *stop) {
        [s appendFormat:@"\t%@ %@ BUY %@ AT %@\n", stringFromOrderStatus(obj.orderStatus), stringFromCurrency(obj.currency), obj.amount.display, obj.price.display];
    }];
    
    [s appendString:@"ASKS:\n"];
    
    [sortedAskOrders enumerateObjectsUsingBlock:^(Order* obj, NSUInteger idx, BOOL *stop) {
        [s appendFormat:@"\t%@ %@ SELL %@ AT %@\n", stringFromOrderStatus(obj.orderStatus), stringFromCurrency(obj.currency), obj.amount.display, obj.price.display];
    }];
    
    return s;
}

-(void)getOrderData
{
    [_httpController getOrdersWithCompletion:^(NSArray *orders) {
        [self setOrders:orders];
        [self.tradeDataTextView setString:ordersArrayToString(orders)];
    } withFailBlock:^(NSError *e) {
        RUDLog(@"Get Order Data Failed");
    }];
}

-(void)getAccountData
{
    [_httpController loadAccountDataWithCompletion:^(NSDictionary* accountInformation) {
        [self setAccount:accountFromDictionary(accountInformation)];
        [_accountDataTextView setString:accountToString(self.account)];
    } andFailBlock:^(NSError *e) {
        RUDLog(@"Get Account Data Failed");
    }];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBorderWidth:2.f];
        [self setBorderColor:[NSColor blackColor]];
        [self setTitle:@"Account"];
        
        [self setHttpController:[TTGoxHTTPController sharedInstance]];
        [self getAccountData];
        [self getOrderData];
    }
    return self;
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    NSRect contentFrame = [(NSView*)self.contentView frame];
    CGFloat columnWidth = floorf(CGRectGetWidth(contentFrame) / 4);
    NSRect f = (NSRect){0, 0, columnWidth, CGRectGetHeight(contentFrame)};
    if (!self.accountDataTextView)
    {
        [self setAccountDataScrollView:[[NSScrollView alloc]initWithFrame:(NSRect){f.origin.x, f.origin.y, f.size.width, f.size.height}]];
        [_accountDataScrollView setBorderType:NSNoBorder];
        [_accountDataScrollView setBackgroundColor:[NSColor clearColor]];
        [_accountDataScrollView setDrawsBackground:NO];
        [_accountDataScrollView setHasVerticalScroller:YES];
        [_accountDataScrollView setHasHorizontalScroller:NO];
        [_accountDataScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self.contentView addSubview:_accountDataScrollView];
        
        [self setAccountDataTextView:[[TTTextView alloc]initWithFrame:(NSRect){f.origin.x, f.origin.y, f.size.width, f.size.height}]];
        [_accountDataTextView setDrawsBackground:NO];
        [_accountDataTextView setFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]];
        [_accountDataTextView setEditable:NO];
        [_accountDataTextView setSelectable:NO];
        [_accountDataTextView setVerticallyResizable:YES];
        [_accountDataTextView setHorizontallyResizable:NO];
        [_accountDataTextView setAutoresizingMask:NSViewWidthSizable];
        [[_accountDataTextView textContainer] setWidthTracksTextView:YES];
        
        NSSize s = [_accountDataScrollView contentSize];
        [_accountDataTextView setFrame:(NSRect){0,0,s.width, s.height}];
        [_accountDataTextView setMinSize:(NSSize){0.f, s.height}];
        [_accountDataTextView setMaxSize:(NSSize){FLT_MAX, FLT_MAX}];
        [_accountDataTextView.textContainer setContainerSize:(NSSize){s.width, FLT_MAX}];
        
        [_accountDataScrollView setDocumentView:_accountDataTextView];
    }
    else
    {
        NSSize s = [_accountDataScrollView contentSize];
        [_accountDataTextView setFrame:(NSRect){0,0,s.width, s.height}];
        [_accountDataTextView setMinSize:(NSSize){0.f, s.height}];
        [_accountDataTextView setMaxSize:(NSSize){FLT_MAX, FLT_MAX}];
        [_accountDataTextView.textContainer setContainerSize:(NSSize){s.width, FLT_MAX}];
    }
    
    if (!self.tradeDataScrollView)
    {
        [self setTradeDataScrollView:[[NSScrollView alloc]initWithFrame:(NSRect){_accountDataScrollView.frame.size.width, 0, 2 * columnWidth, CGRectGetHeight(contentFrame)}]];
        [_tradeDataScrollView setBorderType:NSNoBorder];
        [_tradeDataScrollView setBackgroundColor:[NSColor clearColor]];
        [_tradeDataScrollView setDrawsBackground:NO];
        [_tradeDataScrollView setHasVerticalScroller:YES];
        [_tradeDataScrollView setHasHorizontalScroller:NO];
        [_tradeDataScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self.contentView addSubview:_tradeDataScrollView];

        [self setTradeDataTextView:[[TTTextView alloc]initWithFrame:self.tradeDataScrollView.frame]];
        [_tradeDataTextView setDrawsBackground:NO];
        [_tradeDataTextView setFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]];
        [_tradeDataTextView setEditable:NO];
        [_tradeDataTextView setSelectable:NO];
        [_tradeDataTextView setVerticallyResizable:YES];
        [_tradeDataTextView setHorizontallyResizable:NO];
        [_tradeDataTextView setAutoresizingMask:NSViewWidthSizable];
        [[_tradeDataTextView textContainer] setWidthTracksTextView:YES];
        
        NSSize s = [_tradeDataScrollView contentSize];
        [_tradeDataTextView setFrame:(NSRect){0,0,s.width, s.height}];
        [_tradeDataTextView setMinSize:(NSSize){0.f, s.height}];
        [_tradeDataTextView setMaxSize:(NSSize){FLT_MAX, FLT_MAX}];
        [_tradeDataTextView.textContainer setContainerSize:(NSSize){s.width, FLT_MAX}];
        
        [_tradeDataScrollView setDocumentView:_tradeDataTextView];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
//    [[NSColor orangeColor] setFill];
//    NSRectFill(dirtyRect);
}

@end
