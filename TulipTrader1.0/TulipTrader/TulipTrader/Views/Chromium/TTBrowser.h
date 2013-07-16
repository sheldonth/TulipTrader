//
//  TTBrowser.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/11/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "CTBrowser.h"
#import "TTOrderBook.h"

@interface TTBrowser : CTBrowser

-(id)initWithCurrencies:(NSArray*)currencies;

@property(nonatomic, retain)TTOrderBook* orderBook;

@end
