//
//  TTNewOrderBookWindow.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/23/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TTNewOrderBookWindow;

@protocol TTNewOrderBookWindowDelegate <NSObject>

-(void)didFinishSelectionForWindow:(TTNewOrderBookWindow*)window currencies:(NSArray*)currencies;

@end

@interface TTNewOrderBookWindow : NSWindow <NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate>

@property(nonatomic, retain)id<TTNewOrderBookWindowDelegate>orderBookWindowDelegate;

@end
