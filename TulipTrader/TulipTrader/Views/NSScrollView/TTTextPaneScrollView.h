//
//  TTTextPaneScrollView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/4/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTTextView.h"

@interface TTTextPaneScrollView : NSScrollView

@property(nonatomic, retain, readonly)TTTextView* textView;

@end
