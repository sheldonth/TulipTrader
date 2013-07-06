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
        @synchronized(self.pendingUpdates)
        {
            [self.tableView beginUpdates];
            for (TTDepthUpdate* update in self.pendingUpdates) {
                NSInteger index = update.affectedIndex;
    //            NSInteger index = self.invertsDataSource ? update.affectedIndex - 1 : update.affectedIndex;
                switch (update.updateType) {
                    case TTDepthOrderUpdateTypeInsert:
                        [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NSTableViewAnimationSlideDown];
                        break;
                        
                    case TTDepthOrderUpdateTypeRemove:
                        [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NSTableViewAnimationSlideUp];
                        break;
                        
                    case TTDepthOrderUpdateTypeUpdate:
                        [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.tableColumns.count)]];
                        break;
                        
                    case TTDepthOrderUpdateTypeNone:
                        
                        break;
                        
                    default:
                        break;
                }
            };
            [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfRows)] columnIndexes:[self.tableView.tableColumns indexesOfObjectsPassingTest:^BOOL(NSTableColumn* obj, NSUInteger idx, BOOL *stop) {
                if ([[obj identifier]isEqualToString:@"sum"])
                {
                    *stop = YES;
                    return YES;
                }
                else
                    return NO;
            }]];
            [self.tableView endUpdates];
            [self.pendingUpdates removeAllObjects];
        }
}

-(void)updateForDepthUpdate:(TTDepthUpdate*)update
{
    if (!self.pendingUpdates)
    {
        [self setPendingUpdates:[NSMutableArray array]];
        NSTimer* t = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(processUpdates) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop]addTimer:t forMode:NSDefaultRunLoopMode];
    }
    [self.pendingUpdates addObject:update];
    [self setOrders:[[update updateArrayPointer]copy]];
}

//-(void)updateForDepthUpdate:(TTDepthUpdate*)update
//{
//    [self setOrders:[update.updateArrayPointer copy]];
//
//    switch (update.updateType) {
//        case TTDepthOrderUpdateTypeInsert://1
//        {
//            RUDLog(@"Insert Of %@", [update.updateArrayPointer objectAtIndex:update.affectedIndex]);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableView beginUpdates];
//                [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:update.affectedIndex] withAnimation:NSTableViewAnimationSlideDown];
//                [self.tableView endUpdates];
//            });
//            break;
//        }
//        case TTDepthOrderUpdateTypeRemove://2
//        {
//            RUDLog(@"Removal Of %@", [update.updateArrayPointer objectAtIndex:update.affectedIndex]);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableView beginUpdates];
//                [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:update.affectedIndex] withAnimation:NSTableViewAnimationSlideUp];
//                [self.tableView endUpdates];
//            });
//            break;
//        }
//        case TTDepthOrderUpdateTypeUpdate://3
//        {
//            RUDLog(@"Update Of %@", [update.updateArrayPointer objectAtIndex:update.affectedIndex]);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableView beginUpdates];
//                [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:update.affectedIndex] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.tableColumns.count)]];
//                [self.tableView endUpdates];
//            });
//            break;
//        }
//        case TTDepthOrderUpdateTypeNone://0
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableView reloadData];
//            });
//            break;
//        }
//        default:
//            break;
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(update.affectedIndex, (self.orders.count - update.affectedIndex))] columnIndexes:[self.tableView.tableColumns indexesOfObjectsPassingTest:^BOOL(NSTableColumn* obj, NSUInteger idx, BOOL *stop) {
//            return [obj.identifier isEqualToString:@"sum"];
//        }]];
//    });
//}


#pragma mark - nstableviewdelegate/datasource

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    TTLabelCellView* view = [tableView makeViewWithIdentifier:@"OrderBookListView" owner:self];
    
    if (view== nil)
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
        pertainingDepthOrder = [self.orders objectAtIndex:row];
    }
    NSNumber* result;
    switch (indexSetOfColumn.firstIndex) {
//        case 0:
//            result = @(row);
//            break;

        case 0:
            result = pertainingDepthOrder.price;
            break;

        case 1:
            if (self.invertsDataSource)
            RUDLog(@"row %ld got %@", row, pertainingDepthOrder.amount);
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

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBorderType:NSLineBorder];
        [self setTitlePosition:NSNoTitle];
        [self setBoxType:NSBoxCustom];
        [self setCornerRadius:2.f];
        [self setBorderWidth:2.f];
        [self setBorderColor:[NSColor lightGrayColor]];
        
        [self setContentViewMargins:(NSSize){0, 0}];
        
        [self setColumnsArray:[NSMutableArray array]];
        
        [self setTitleLabel:[[JNWLabel alloc]initWithFrame:(NSRect){CGRectGetMidX([self.contentView bounds]) - 40, CGRectGetHeight([self.contentView bounds]) - 20, 80, 20}]];
        [_titleLabel setFont:titleFontBold];
        [_titleLabel setTextAlignment:NSCenterTextAlignment];
        [self.contentView addSubview:_titleLabel];
    
        [self setScrollView:[[NSScrollView alloc]initWithFrame:(NSRect){0, 0, CGRectGetWidth([self.contentView bounds]),CGRectGetHeight([self.contentView bounds]) - _titleLabel.frame.size.height}]];
        [_scrollView setHasVerticalScroller:YES];
        [_scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self.contentView addSubview:_scrollView];
        
        [self setTableView:[[NSTableView alloc]initWithFrame:(NSRect){0, 0, CGRectGetWidth([self.contentView frame]), CGRectGetHeight([self.contentView frame])}]];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView setUsesAlternatingRowBackgroundColors:YES];
        [_tableView setGridStyleMask:(NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask)];
        
//        [self setPositionColumn:[[NSTableColumn alloc]initWithIdentifier:@"Pos"]];
//        [_positionColumn setEditable:NO];
//        [_positionColumn setWidth:40.f];
//        [[_positionColumn headerCell] setStringValue:@"#"];
//        [_tableView addTableColumn:_positionColumn];
//        [self.columnsArray addObject:_positionColumn];
        
        CGFloat columnWidth = floorf(CGRectGetWidth([self.contentView bounds])/3.f);
        
        [self setPriceColumn:[[NSTableColumn alloc]initWithIdentifier:@"price"]];
        [_priceColumn setEditable:NO];
        [_priceColumn setWidth:columnWidth];
        [[_priceColumn headerCell]setStringValue:@"Price"];
        [_tableView addTableColumn:_priceColumn];
        [self.columnsArray addObject:_priceColumn];
        
        [self setQuantityColumn:[[NSTableColumn alloc]initWithIdentifier:@"amount"]];
        [_quantityColumn setEditable:NO];
        [_quantityColumn setWidth:columnWidth];
        [[_quantityColumn headerCell]setStringValue:@"Quantity"];
        [_tableView addTableColumn:_quantityColumn];
        [self.columnsArray addObject:_quantityColumn];
        
        [self setSumColumn:[[NSTableColumn alloc]initWithIdentifier:@"sum"]];
        [_sumColumn setEditable:NO];
        [_sumColumn setWidth:columnWidth - 20];
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
    [_titleLabel setText:titleString];
}

- (void)drawRect:(NSRect)dirtyRect
{
//    if (NSContainsRect(dirtyRect, self.frame))
    [super drawRect:dirtyRect];
}

@end
