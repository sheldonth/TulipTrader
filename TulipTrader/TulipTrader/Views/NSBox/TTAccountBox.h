//
//  TTAccountBox.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/30/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Tick.h"
#import "TTGoxAccount.h"

@interface TTAccountBox : NSBox

@property(nonatomic, retain)TTGoxAccount* account;
@property(nonatomic, retain)NSArray* orders;

@end
