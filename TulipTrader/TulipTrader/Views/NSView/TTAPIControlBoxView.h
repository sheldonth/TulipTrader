//
//  TTAPIControlBoxView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/6/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RUSingleton.h"

@interface TTAPIControlBoxView : NSView <NSTextFieldDelegate>

RU_SYNTHESIZE_SINGLETON_DECLARATION_FOR_CLASS_WITH_ACCESSOR(TTAPIControlBoxView, sharedInstance);

+(void)publishCommand:(NSString*)commandText;

@end
