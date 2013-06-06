//
//  TTAPIControlBoxView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/6/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RUSingleton.h"

extern NSArray* kTTAPIActionCommandList;
extern NSArray* kTTAPIActionObjectList;
extern NSArray* kTTAPIActionFlagList;

@interface TTAPIControlBoxView : NSBox <NSTextFieldDelegate>

+(void)publishCommand:(NSString*)commandText repeating:(BOOL)repeats;
+(void)publishCommand:(NSString*)commandText;

+(NSString*)currentControlString;

RU_SYNTHESIZE_SINGLETON_DECLARATION_FOR_CLASS_WITH_ACCESSOR(TTAPIControlBoxView, sharedInstance);

@end
