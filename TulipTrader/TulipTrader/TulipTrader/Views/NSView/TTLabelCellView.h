//
//  TTLabelCellView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/2/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JNWLabel.h"

@interface TTLabelCellView : NSTableCellView

@property(nonatomic, retain)NSString* valueString;
@property(nonatomic, retain)NSColor* textColor;
@property(nonatomic)BOOL alignsValue;

@end
