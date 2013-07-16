//
//  TTBrowser.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/11/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTBrowser.h"
#import "TTTabContents.h"

@interface TTBrowser()

@property(nonatomic, retain)NSMutableArray* currencies;

@end

@implementation TTBrowser

-(id)initWithCurrencies:(NSArray*)currencies
{
    self = [super init];
    if (self)
    {
        [self setCurrencies:[currencies mutableCopy]];
    }
    return self;
}

-(CTTabContents *)createBlankTabBasedOn:(CTTabContents *)baseContents
{
    TTTabContents* contents = [[TTTabContents alloc]initWithBaseTabContents:baseContents currency:currencyFromString(@"USD")];
    [self setOrderBook:contents.orderBook];
    return contents;
}

-(CTToolbarController *)createToolbarController
{
    return nil;
}

@end
