//
//  TTNewOrderBookWindow.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/23/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TTCurrencySelectionWindow;

@protocol TTCurrencySelectionWindowDelegate <NSObject>

-(void)didFinishSelectionForWindow:(TTCurrencySelectionWindow*)window currencies:(NSArray*)currencies;

@end

@interface TTCurrencySelectionWindow : NSWindow <NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate>

@property(nonatomic, retain)id<TTCurrencySelectionWindowDelegate>orderBookWindowDelegate;

@end
