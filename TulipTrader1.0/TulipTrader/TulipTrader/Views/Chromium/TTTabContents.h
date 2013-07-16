//
//  TTTabContents.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/11/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "CTTabContents.h"
#import "TTCurrency.h"
#import "TTOrderBook.h"

@interface TTTabContents : CTTabContents

@property(nonatomic)TTCurrency currency;
@property(nonatomic, retain)TTOrderBook* orderBook;

-(id)initWithBaseTabContents:(CTTabContents *)baseContents currency:(TTCurrency)currency;

@end
