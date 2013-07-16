//
//  TTTabContents.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/11/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTTabContents.h"
#import "TTOrderBookView.h"
#import "TTCurrency.h"
#import "RUConstants.h"

@interface TTTabContents()

@property(nonatomic, retain)TTOrderBookView* orderBookView;

@end

@implementation TTTabContents

-(id)initWithBaseTabContents:(CTTabContents *)baseContents currency:(TTCurrency)currency
{
    self = [super initWithBaseTabContents:baseContents];
    if (self)
    {
        [self setCurrency:currency];
        [self setOrderBookView:[[TTOrderBookView alloc]initWithFrame:NSZeroRect currency:currency]];
        [self setView:_orderBookView];
        [self setOrderBook:_orderBookView.orderBook];
    }
    return self;
}

-(void)viewFrameDidChange:(NSRect)newFrame
{
    [super viewFrameDidChange:newFrame];
    [_orderBookView setFrame:newFrame];
}

@end
