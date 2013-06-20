//
//  TTMarketSelectionWelcomeWindow.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/19/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TTMarketSelectionWelcomeWindow;

@protocol MarketSelectionWindowDelegate <NSObject>

-(void)didFinishSelectionForWindow:(TTMarketSelectionWelcomeWindow*)window currencies:(NSArray*)currencies;

@end

@interface TTMarketSelectionWelcomeWindow : NSWindow <NSTableViewDataSource, NSTableViewDelegate>

@property(nonatomic, retain)id<MarketSelectionWindowDelegate>marketSelectionDelegate;

@end
