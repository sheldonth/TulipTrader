//
//  TTStatusBox.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/3/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTOrderBook.h"

@interface TTStatusBox : NSBox <TTOrderBookEventDelegate>

@end
