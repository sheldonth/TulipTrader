//
//  TTOrderBookListView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/26/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTOrderBookListView.h"
#import "JNWLabel.h"
#import "RUConstants.h"
#import "TTDepthOrder.h"
#import "TTOrderBook.h"
#import "TTLabelCellView.h"

@interface TTOrderBookListView()

@property(nonatomic, retain)NSScrollView* scrollView;
@property(nonatomic, retain)NSTableView* tableView;
@property(nonatomic, retain)JNWLabel* titleLabel;
@property(nonatomic, retain)NSMutableArray* columnsArray;
@property(nonatomic, retain)NSMutableArray* pendingUpdates;

@property(nonatomic, retain)dispatch_queue_t ordersUpdateDispatchQueue;

@end

static NSFont* titleFont;
static NSFont* titleFontBold;

@implementation TTOrderBookListView

+(void)initialize
{
    if (self == [TTOrderBookListView class])
    {
        titleFont = [NSFont fontWithName:@"Menlo" size:12.f];
        titleFontBold = [NSFont fontWithName:@"Menlo-Bold" size:12.f];
    }
}

#pragma mark - public methods

-(void)processUpdates
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (TTDepthUpdate* update in self.pendingUpdates) {
            
            [self setOrders:[[update updateArrayPointer]copy]];
            
            NSInteger index = update.affectedIndex;
            
            switch (update.updateType) {
                case TTDepthOrderUpdateTypeInsert:
                    if (self.invertsDataSource)
                    {
                        [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:self.orders.count - 1 - index] withAnimation:NSTableViewAnimationSlideDown];
                    }
                    else
                    {
                        [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NSTableViewAnimationSlideDown];
                    }
                    break;
                    
                case TTDepthOrderUpdateTypeRemove:
                    if (self.invertsDataSource)
                    {
                        [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:self.orders.count - index] withAnimation:NSTableViewAnimationSlideUp];
                    }
                    else
                    {
                        [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NSTableViewAnimationSlideUp];
                    }
                    break;
                    
                case TTDepthOrderUpdateTypeUpdate:
                    if (self.invertsDataSource)
                    {
                        [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:self.orders.count - 1 - index] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.tableColumns.count)]];
                    }
                    else
                        [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.tableColumns.count)]];

                    break;
                    
                case TTDepthOrderUpdateTypeNone:
                    
                    break;
                    
                    
                default:
                    break;
            }
        };
        NSIndexSet* indexesBehindThisOne = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.orders.count)];
        
        NSIndexSet* sumColumn  = [self.tableView.tableColumns indexesOfObjectsPassingTest:^BOOL(NSTableColumn* obj, NSUInteger idx, BOOL *stop) {
            if ([[obj identifier]isEqualToString:@"sum"])
            {
                *stop = YES;
                return YES;
            }
            else
                return NO;
        }];
        
        [self.tableView reloadDataForRowIndexes:indexesBehindThisOne columnIndexes:sumColumn];
        [self.pendingUpdates removeAllObjects];
    });
}

-(void)updateForDepthUpdate:(TTDepthUpdate*)update
{
    if (!self.pendingUpdates)
    {
        [self setPendingUpdates:[NSMutableArray array]];
        NSTimer* t = [NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(processUpdates) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop]addTimer:t forMode:NSDefaultRunLoopMode];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.pendingUpdates addObject:update];
    });
}

#pragma mark - nstableviewdelegate/datasource

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (!(row < self.orders.count))
    {NSException* e = [[NSException alloc]initWithName:NSInternalInconsistencyException reason:@"Bad number of rows for self.orders count" userInfo:nil];@throw e;}

    TTLabelCellView* view = [tableView makeViewWithIdentifier:@"OrderBookListView" owner:self];
    
    if (view == nil)
    {
        view = [[TTLabelCellView alloc]initWithFrame:(NSRect){0, 0, tableColumn.width, 20}];
        [view setIdentifier:@"OrderBookListView"];
    }
    
    NSIndexSet* indexSetOfColumn = [self.columnsArray indexesOfObjectsPassingTest:^BOOL(NSTableColumn* obj, NSUInteger idx, BOOL *stop) {
        if ([obj.identifier isEqualToString:tableColumn.identifier])
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (indexSetOfColumn.count != 1)
        RUDLog(@"Found TWO Columns Passing Test");
    TTDepthOrder* pertainingDepthOrder;
    if (self.invertsDataSource)
        pertainingDepthOrder = [self.orders objectAtIndex:(self.orders.count - 1 - row)];
    else
    {
        if (row < self.orders.count)
            pertainingDepthOrder = [self.orders objectAtIndex:row];
        else
        {
            NSException* e = [[NSException alloc]initWithName:NSInternalInconsistencyException reason:@"row was not less than the count of self.orders" userInfo:nil];
            @throw e;
        }
    }
    NSNumber* result;
    switch (indexSetOfColumn.firstIndex) {
        case 0:
            result = pertainingDepthOrder.price;
            break;

        case 1:
            result = pertainingDepthOrder.amount;
            break;
            
        case 2:
        {
            @synchronized(self.orders)
            {
                double sum = 0.0;
                if (self.invertsDataSource)
                {
                    int idx = (int)[self.orders indexOfObject:pertainingDepthOrder];
                    for (int i = idx; i < self.orders.count; i++) {
                        sum = sum + [[[self.orders objectAtIndex:i] amount]doubleValue];
                    }
                }
                else
                {
                    for (int i = 0; i < (row + 1); i++) {
                        sum = sum + [[[self.orders objectAtIndex:i] amount]doubleValue];
                    }
                }
                    
                result = @(sum);
                break;
            }
        }

        default:
            break;
    }
    [view setValueString:RUStringWithFormat(@"%.5f", result.floatValue)];
    return view;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 20.f;
}

-(NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSCell* aCell = [[NSTextFieldCell alloc]initTextCell:@"sheldon"];
    return aCell;
}

-(BOOL)tableView:(NSTableView *)tableView shouldReorderColumn:(NSInteger)columnIndex toColumn:(NSInteger)newColumnIndex
{
    return YES;
}

-(BOOL)tableView:(NSTableView *)tableView shouldShowCellExpansionForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return NO;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.orders.count;
}

-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    RUDLog(@"");
}

-(void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    RUDLog(@"");
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    CGFloat columnWidth = floorf(CGRectGetWidth([self.contentView bounds])/3.f);
    [_titleLabel setFrame:(NSRect){CGRectGetMidX([self.contentView bounds]) - 40, CGRectGetHeight([self.contentView bounds]) - 18, 80, 15}];
    [_scrollView setFrame:(NSRect){0, 0, CGRectGetWidth([self.contentView bounds]),CGRectGetHeight([self.contentView bounds]) - _titleLabel.frame.size.height - 5}];
    [_tableView setFrame:(NSRect){0, 0, CGRectGetWidth([self.contentView frame]), CGRectGetHeight([self.contentView frame])}];
    [_priceColumn setWidth:columnWidth];
    [_quantityColumn setWidth:columnWidth];
    [_sumColumn setWidth:columnWidth - 20];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBorderType:NSLineBorder];
        [self setTitlePosition:NSNoTitle];
        [self setBoxType:NSBoxCustom];
        [self setCornerRadius:2.f];
        [self setBorderWidth:2.f];
        [self setBorderColor:[NSColor whiteColor]];
        
        [self setOrdersUpdateDispatchQueue:dispatch_queue_create("com.tuliptrader.OrderBookListViewDispatch", NULL)];
        
        [self setContentViewMargins:(NSSize){0, 0}];
        
        [self setColumnsArray:[NSMutableArray array]];
        
        [self setTitleLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_titleLabel setFont:titleFontBold];
        [_titleLabel setTextAlignment:NSCenterTextAlignment];
        [self.contentView addSubview:_titleLabel];
    
        [self setScrollView:[[NSScrollView alloc]initWithFrame:NSZeroRect]];
        [_scrollView setHasVerticalScroller:YES];
        [_scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self.contentView addSubview:_scrollView];
        
        [self setTableView:[[NSTableView alloc]initWithFrame:NSZeroRect]];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView setUsesAlternatingRowBackgroundColors:YES];
        [_tableView setGridStyleMask:(NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask)];
        [_tableView setAllowsColumnReordering:YES];
        [_tableView setAllowsColumnResizing:YES];
        [_tableView setAllowsExpansionToolTips:YES];
        [_tableView setAllowsMultipleSelection:YES];
        
        [self setPriceColumn:[[NSTableColumn alloc]initWithIdentifier:@"price"]];
        [_priceColumn setEditable:NO];
        [[_priceColumn headerCell]setStringValue:@"Price"];
        [_tableView addTableColumn:_priceColumn];
        [self.columnsArray addObject:_priceColumn];
        
        [self setQuantityColumn:[[NSTableColumn alloc]initWithIdentifier:@"amount"]];
        [_quantityColumn setEditable:NO];
        [[_quantityColumn headerCell]setStringValue:@"Quantity"];
        [_tableView addTableColumn:_quantityColumn];
        [self.columnsArray addObject:_quantityColumn];
        
        [self setSumColumn:[[NSTableColumn alloc]initWithIdentifier:@"sum"]];
        [_sumColumn setEditable:NO];
        [[_sumColumn headerCell]setStringValue:@"Sum"];
        [_tableView addTableColumn:_sumColumn];
        [self.columnsArray addObject:_sumColumn];

        [_scrollView setDocumentView:_tableView];
    }
    return self;
}

-(void)setOrders:(NSArray *)orders
{
    BOOL firstLoad = NO;
    if (!self.orders)
        firstLoad = YES;
    [self willChangeValueForKey:@"orders"];
    _orders = orders;
    [self didChangeValueForKey:@"orders"];
    if (firstLoad)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
}

-(void)setTitle:(NSString*)titleString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_titleLabel setText:titleString];
    });
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

@end
