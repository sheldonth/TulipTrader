//
//  TTDepthGridViewColumnView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/17/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTGoxCurrency.h"
#import "TTDepthStackView.h"

@interface TTDepthGridViewColumnView : NSView <TTDepthStackViewXAxisDelegate>

@property(nonatomic)TTGoxCurrency currency;

@end
