//
//  TTDepthStackView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/13/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTGoxCurrency.h"

@interface TTDepthStackView : NSView

@property(nonatomic, readwrite)TTGoxCurrency currency;
@property(nonatomic)BOOL hasSeededDepthData;
@property(nonatomic)BOOL lineDataIsDirty;

-(void)reload;

@end
