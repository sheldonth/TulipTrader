//
//  TTTabBarView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/10/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTOrderBookView.h"

@protocol TTTabBarViewSelectionDelegate <NSObject>

-(void)didSelectViewAtIndex:(NSInteger)index;

@end

@interface TTTabBarView : NSView

-(void)addOrderBookView:(TTOrderBookView*)orderBookView;

@property(nonatomic)id <TTTabBarViewSelectionDelegate> delegate;

@end
