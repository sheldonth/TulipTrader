//
//  TTOrderBookWindow.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/10/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTCurrency.h"
#import "TTTabBarView.h"

@interface TTOrderBookWindow : NSWindow <TTTabBarViewSelectionDelegate>

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag currencies:(NSArray*)currencies;

@end
