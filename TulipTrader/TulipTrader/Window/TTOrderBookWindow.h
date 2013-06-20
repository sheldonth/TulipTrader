//
//  TTOrderBookWindow.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/19/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTMasterViewController.h"

@interface TTOrderBookWindow : NSWindow

@property(nonatomic, retain)NSArray* currencies;
@property(nonatomic, retain)TTMasterViewController* masterViewController;

@end
