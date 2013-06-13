//
//  TTMenuBehaviorController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/8/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUSingleton.h"
#import "TTAppDelegate.h"

@interface TTMenuBehaviorController : NSObject

RU_SYNTHESIZE_SINGLETON_DECLARATION_FOR_CLASS_WITH_ACCESSOR(TTMenuBehaviorController, sharedInstance);

@property(nonatomic, readonly, assign)NSMenu* menu;
@property(weak)TTAppDelegate* appDelegate;

@end
