//
//  TTMarketSelectionWelcomeWindow.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/19/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTMarketSelectionWelcomeWindow.h"
#import "JNWLabel.h"
#import "RUConstants.h"
#import "TTGoxCurrencyController.h"
#import <Carbon/Carbon.h>

@interface TTMarketSelectionWelcomeWindow()

@property(nonatomic, retain)JNWLabel* titleLabel;
@property(nonatomic, retain)JNWLabel* versionLabel;
@property(nonatomic, retain)NSTableView* currenciesTableView;
@property(nonatomic, retain)NSScrollView* currenciesTableScrollView;
@property(nonatomic, retain)TTGoxCurrencyController* currencyController;
@property(nonatomic, retain)NSButton* completeButton;

@end

@implementation TTMarketSelectionWelcomeWindow

#pragma mark - Keyboard method overrides

// kVK_Return is in an archaic file /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers
// Events.h which is included by <Carbon/Carbon.h>

-(void)keyDown:(NSEvent *)theEvent
{
    if (theEvent.keyCode == kVK_Return)
    {
        [self finishAndInformDelegate];
    }
}

#pragma mark - UIButton methods

-(void)completeButtonPressed:(NSButton*)sender
{
    [self finishAndInformDelegate];
}

#pragma mark - NSTableViewDataSource methods

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    switch (tableView.tag) {
        case 1:
            return self.currencyController.currencies.count;
            break;
            
        default:
            return 0;
            break;
    }
}

-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    [TTGoxCurrencyController setCurrency:currencyFromString([self.currencyController.currencies objectAtIndex:row]) active:[(NSNumber*)object boolValue]];
    [tableView reloadData];
}

-(NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSButtonCell* cell = [[NSButtonCell alloc]init];
    [cell setButtonType:NSSwitchButton];
    [cell setEnabled:YES];
    [cell setTitle:[self.currencyController.currencies objectAtIndex:row]];
    return cell;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [[TTGoxCurrencyController activeCurrencys]containsObject:[self.currencyController.currencies objectAtIndex:row]] ? @(1) : @(0);
}

#pragma mark - NSTableViewDelegate methods

#pragma mark - internal methods

-(void)finishAndInformDelegate
{
    NSMutableArray* selectedCurrenciesArray = [NSMutableArray array];
    NSIndexSet* selectedCurrenciesIndexSet = [self.currenciesTableView selectedRowIndexes];
    [selectedCurrenciesIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [selectedCurrenciesArray addObject:[self.currencyController.currencies objectAtIndex:idx]];
    }];
    [self.marketSelectionDelegate didFinishSelectionForWindow:self currencies:selectedCurrenciesArray];
}

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self)
    {
        NSRect bounds = [(NSView*)self.contentView bounds];
        
        [self setCurrencyController:[[TTGoxCurrencyController alloc]init]];
        
        [self setTitleLabel:[[JNWLabel alloc]initWithFrame:(NSRect){CGRectGetMidX(bounds) - 100, CGRectGetHeight(bounds) - 60, 200, 50}]];
        [_titleLabel setTextAlignment:NSCenterTextAlignment];
        [_titleLabel setFont:[NSFont systemFontOfSize:24.f]];
        [_titleLabel setText:@"TulipTrader"];
        [self.contentView addSubview:_titleLabel];
        
        [self setVersionLabel:[[JNWLabel alloc]initWithFrame:(NSRect){CGRectGetMidX(bounds) - 90, CGRectGetHeight(bounds) - 100, 180, 60}]];
        [_versionLabel setTextAlignment:NSCenterTextAlignment];
        [_versionLabel setFont:[NSFont systemFontOfSize:12.f]];
        NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
        [_versionLabel setText:RUStringWithFormat(@"v%@\n© 2013 Sheldon Thomas\nsheldon.thomas@me.com", version)];
        
        [self.contentView addSubview:_versionLabel];
        
        
        [self setCurrenciesTableScrollView:[[NSScrollView alloc]initWithFrame:(NSRect){CGRectGetMidX(bounds) - 75, 100, 150, 200}]];
        
        [self setCurrenciesTableView:[[NSTableView alloc]initWithFrame:_currenciesTableScrollView.frame]];
        [_currenciesTableView setTag:1];
        [_currenciesTableView setDataSource:self];
        [_currenciesTableView setDelegate:self];
        [_currenciesTableView setAllowsMultipleSelection:YES];
        
        NSTableColumn* column = [[NSTableColumn alloc]initWithIdentifier:@"CurrencyListColumn"];
        [column setWidth:150.f];
        [[column headerCell]setStringValue:@"MTGOX ORDER BOOKS"];
        [_currenciesTableView addTableColumn:column];
        
        [_currenciesTableScrollView setHasVerticalScroller:YES];
        [_currenciesTableScrollView setDocumentView:_currenciesTableView];
        
        [self.contentView addSubview:_currenciesTableScrollView];
        
        [self setCompleteButton:[[NSButton alloc]initWithFrame:(NSRect){CGRectGetMidX(bounds) - 25, 25, 50, 50}]];
        [_completeButton setTitle:@"GO"];
        [_completeButton setTarget:self];
        [_completeButton setAction:@selector(completeButtonPressed:)];
        [self.contentView addSubview:_completeButton];
    }
    return self;
}

@end
