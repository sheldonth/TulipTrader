//
//  TTVerticalOBGraphView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/9/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTOrderBook.h"

@interface TTVerticalOBGraphView : NSView

-(void)updateForBidSide:(TTDepthUpdate*)depthUpdate;
-(void)updateForAskSide:(TTDepthUpdate*)depthUpdate;

@end
