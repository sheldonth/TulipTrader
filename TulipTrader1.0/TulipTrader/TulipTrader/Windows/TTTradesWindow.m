//
//  TTTradesWindow.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/7/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTTradesWindow.h"
#import "TTLabelCellView.h"
#import "RUConstants.h"
#import "TTCurrency.h"
#import "TTTrade.h"

@interface TTTradesWindow()
{
    NSDateFormatter* timeFormatter;
}

@property(nonatomic, retain)NSArray* columnTitleArray;
@property(nonatomic, retain)NSMutableArray* columnArray;
@property(nonatomic, retain)NSSortDescriptor* sortDescriptor;
@property(nonatomic)BOOL ascending;
@property(nonatomic)NSInteger indexOfSelectedColumn;

@end

@implementation TTTradesWindow

-(void)addTrade:(TTTrade *)trade
{
        NSMutableArray* tradesCpy = [self.trades mutableCopy];
        [tradesCpy addObject:trade];
        NSSortDescriptor* s = nil;

        switch (self.indexOfSelectedColumn) {
            case 0:
            {
                s = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:self.ascending];
                break;
            }
                
            case 1:
            {
                s = [NSSortDescriptor sortDescriptorWithKey:@"currency" ascending:self.ascending];
                break;
            }
                
            case 2:
            {
                s = [NSSortDescriptor sortDescriptorWithKey:@"price" ascending:self.ascending];
                break;
            }
                
            case 3:
            {
                s = [NSSortDescriptor sortDescriptorWithKey:@"amount" ascending:self.ascending];
                break;
            }
                
            default:
                break;
        }
        if (s)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setTrades:[tradesCpy sortedArrayUsingDescriptors:@[s]]];
                NSInteger indexOfUpdate = [self.trades indexOfObject:trade];
                [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:indexOfUpdate] withAnimation:NSTableViewAnimationSlideDown];
            });
        }
}

-(void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    
}

-(void)tableView:(NSTableView *)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn
{

}

-(void)clearTableColumnSelectionsForTableView:(NSTableView*)tableView
{
    [self.columnArray enumerateObjectsUsingBlock:^(NSTableColumn* obj, NSUInteger idx, BOOL *stop) {
        [tableView setIndicatorImage:nil inTableColumn:obj];
    }];
}

-(void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
    NSInteger index = [self.columnArray indexOfObject:tableColumn];
    NSString* columnSortDescriptorKey;
    switch (index) {
        case 0:
            columnSortDescriptorKey = @"date";
            break;
        
        case 1:
            columnSortDescriptorKey = @"currency";
            break;
            
        case 2:
            columnSortDescriptorKey = @"price";
            break;
            
        case 3:
            columnSortDescriptorKey = @"amount";
            break;
            
        default:
            columnSortDescriptorKey = nil;
            break;
    }
    if (columnSortDescriptorKey)
    {
        if (self.indexOfSelectedColumn == index)
        {
            self.ascending ? [self.tableView setIndicatorImage:[NSImage imageNamed:@"NSDescendingSortIndicator"] inTableColumn:tableColumn] : [self.tableView setIndicatorImage:[NSImage imageNamed:@"NSAscendingSortIndicator"] inTableColumn:tableColumn];
            [self setAscending:!self.ascending];
        }
        else
        {
            [self clearTableColumnSelectionsForTableView:tableView];
            [self.tableView setIndicatorImage:[NSImage imageNamed:@"NSDescendingSortIndicator"] inTableColumn:tableColumn];
            [self setAscending:NO];
            [self setIndexOfSelectedColumn:index];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setTrades:[self.trades sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:columnSortDescriptorKey ascending:self.ascending]]]];
            [self.tableView reloadData];
        });
    }
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 20.f;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    TTLabelCellView* cellView = [tableView makeViewWithIdentifier:@"TradesTableView" owner:self];
    
    if (cellView == nil)
    {
        cellView = [[TTLabelCellView alloc]initWithFrame:(NSRect){0, 0, tableColumn.width, 20.f}];
        [cellView setIdentifier:@"TradesTableView"];
    }
    NSIndexSet* indexSetOfColumn = [self.columnArray indexesOfObjectsPassingTest:^BOOL(NSTableColumn* obj, NSUInteger idx, BOOL *stop) {
        if ([obj.identifier isEqualToString:tableColumn.identifier])
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    TTTrade* trade = [self.trades objectAtIndex:row];
    
    switch (indexSetOfColumn.firstIndex) {
        case 0:
            [cellView setValueString:[timeFormatter stringFromDate:trade.date]];
            break;
            
        case 1:
            [cellView setValueString:RUStringWithFormat(@"%@", stringFromCurrency(currencyFromNumber(trade.currency)))];
            break;
            
        case 2:
            [cellView setValueString:RUStringWithFormat(@"%.5f", trade.price.floatValue)];
            break;
            
        case 3:
            [cellView setValueString:RUStringWithFormat(@"%@", trade.amount)];
            break;
            
        case 4:
        {
            double tradeVal = trade.amount.floatValue * trade.price.floatValue;
            [cellView setValueString:RUStringWithFormat(@"%@%.2f", currencySymbolStringFromCurrency(currencyFromNumber(trade.currency)), tradeVal)];
            break;
        }
            
        case 5:
        {
            switch (trade.trade_type) {
                case TTTradeTypeBid:
                    [cellView setValueString:@"BID"];
                    break;
                    
                case TTTradeTypeAsk:
                    [cellView setValueString:@"ASK"];
                    break;
                    
                case TTTradeTypeNone:
                    
                    break;
                    
                default:
                    break;
            }
            break;
        }
            
        case 6:
        {
            if (self.indexOfSelectedColumn == 0)
            {
                __block double sum = 0;
                __block double count = 0;
                
                [self.trades enumerateObjectsUsingBlock:^(TTTrade* obj, NSUInteger idx, BOOL *stop) {
                    if (obj.trade_type != trade.trade_type)
                    {
                        *stop = YES;
                    }
                    else
                    {
                        sum = sum + obj.amount.doubleValue;
                        count++;
                    }
                }];
                [cellView setValueString:RUStringWithFormat(@"%.1f", sum)];
            }
            else
            {
                [cellView setValueString:@"--"];
            }
            break;
        }
            

        default:
            break;
    }
    return cellView;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.trades.count;
}

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self)
    {
        timeFormatter = [NSDateFormatter new];
        
        [timeFormatter setDateFormat:@"hh:mm:ss"];
        
        _columnTitleArray = @[@"Time", @"Currency", @"Price", @"Volume", @"Eq. Value", @"Trade Type", @"Trend"];
        _columnArray = [NSMutableArray array];
        
        _scrollView = [[NSScrollView alloc]initWithFrame:(NSRect){0, 0, CGRectGetWidth([self.contentView frame]), CGRectGetHeight([self.contentView frame])}];
        [_scrollView setHasVerticalScroller:YES];
        [_scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        _tableView = [[NSTableView alloc]initWithFrame:(NSRect){0, 0, CGRectGetWidth([self.contentView frame]), CGRectGetHeight([self.contentView frame])}];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView setUsesAlternatingRowBackgroundColors:YES];
        [_tableView setGridStyleMask:(NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask)];
        [_tableView setAllowsColumnReordering:YES];
        [_tableView setAllowsColumnResizing:YES];
        [_tableView setAllowsExpansionToolTips:YES];
        [_tableView setAllowsMultipleSelection:YES];
        [_tableView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        CGFloat columnWidth = floorf(CGRectGetWidth([self.contentView frame]) / (float)self.columnTitleArray.count);
        
        [self.columnTitleArray enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
            NSTableColumn* column = [[NSTableColumn alloc]initWithIdentifier:obj];
            [column setEditable:NO];
            [column setWidth:columnWidth];
            [[column headerCell]setStringValue:obj];
            [_tableView addTableColumn:column];
            [self.columnArray addObject:column];
        }];
        
        [self.tableView setIndicatorImage:[NSImage imageNamed:@"NSDescendingSortIndicator"] inTableColumn:[self.columnArray objectAtIndex:0]];
        [self setAscending:NO];
        [self setIndexOfSelectedColumn:0];
        
        [_scrollView setDocumentView:_tableView];
        [self.contentView addSubview:_scrollView];
    }
    return self;
}

-(void)setTrades:(NSArray *)trades
{
    [self willChangeValueForKey:@"trades"];
    _trades = trades;
    [self didChangeValueForKey:@"trades"];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.tableView reloadData];
    });
}



@end
