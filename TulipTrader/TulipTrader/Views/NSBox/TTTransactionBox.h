//
//  TTTransactionBox.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/6/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Transaction.h"

@interface TTTransactionBox : NSBox

@property(nonatomic, retain)Transaction* transaction;

@end
