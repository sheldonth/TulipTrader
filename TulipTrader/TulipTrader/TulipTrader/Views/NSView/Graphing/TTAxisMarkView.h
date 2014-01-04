//
//  TTAxisMarkView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/10/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JNWLabel.h"

@interface TTAxisMarkView : NSView

@property(nonatomic, retain)JNWLabel* label;

@property(nonatomic)CGFloat tickLength;

@end
