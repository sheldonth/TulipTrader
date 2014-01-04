//
//  TTAxisView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/9/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TTAxisView : NSView

- (id)initWithFrame:(NSRect)frame contentOriginOffset:(CGFloat)contentOriginOffset maxPlottedValue:(NSInteger)maxPlotValue interval:(NSInteger)interval;

@end
