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

@interface TTOrderBookListView()

@property(nonatomic, retain)NSScrollView* scrollView;
@property(nonatomic, retain)NSTableView* tableView;
@property(nonatomic, retain)JNWLabel* titleLabel;

@end

static NSFont* titleFont;

@implementation TTOrderBookListView

+(void)initialize
{
    if (self == [TTOrderBookListView class])
    {
        titleFont = [NSFont fontWithName:@"Menlo" size:12.f];
    }
}

#pragma mark - nstableviewdelegate/datasource

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    TTDepthOrder* cellDepthOrder = [self.orders objectAtIndex:row];
    return @1;
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
        
        [self setTitleLabel:[[JNWLabel alloc]initWithFrame:(NSRect){CGRectGetMidX(self.bounds) - 40, CGRectGetHeight(self.bounds) - 20, 80, 20}]];
        [_titleLabel setFont:titleFont];
//        [_titleLabel setDrawsBackground:YES];
//        [_titleLabel setBackgroundColor:[NSColor redColor]];
        [_titleLabel setTextAlignment:NSCenterTextAlignment];
        [self addSubview:_titleLabel];
    
        [self setScrollView:[[NSScrollView alloc]initWithFrame:(NSRect){1, 1, CGRectGetWidth(self.bounds) - 3,CGRectGetHeight(self.bounds) - _titleLabel.frame.size.height}]];
        [self addSubview:_scrollView];
        
        [self setTableView:[[NSTableView alloc]initWithFrame:_scrollView.frame]];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        
        [self setPositionColumn:[[NSTableColumn alloc]initWithIdentifier:@"Position"]];
        [_positionColumn setEditable:NO];
        [_positionColumn setWidth:20.f];
        [[_positionColumn headerCell] setStringValue:@"#"];
        [_tableView addTableColumn:_positionColumn];
        
        [self setPriceColumn:[[NSTableColumn alloc]initWithIdentifier:@"Price"]];
        [_priceColumn setEditable:NO];
//        [_priceColumn setDataCell:]
        [_priceColumn setWidth:40.f];
        [[_priceColumn headerCell]setStringValue:@"Price"];
        [_tableView addTableColumn:_priceColumn];
        
        [_scrollView setDocumentView:_tableView];
    }
    return self;
}

-(void)setOrders:(NSArray *)orders
{
    [self willChangeValueForKey:@"orders"];
    _orders = orders;
    [self didChangeValueForKey:@"orders"];
    [self.tableView reloadData];
}

-(void)setTitle:(NSString*)titleString
{
    [_titleLabel setText:titleString];
}

- (void)drawRect:(NSRect)dirtyRect
{
//    if (NSContainsRect(dirtyRect, self.frame))
    if(NSEqualRects(dirtyRect, self.bounds)) // Only stroke the gray border when we're painting the whole pony
    {
        [[NSColor lightGrayColor]set];
        NSBezierPath* outerStroke = [NSBezierPath bezierPathWithRect:(NSRect){dirtyRect.origin.x, dirtyRect.origin.y, dirtyRect.size.width - 1, dirtyRect.size.height}];
        [outerStroke stroke];
    }
}

@end
