//
//  TTGoxSocketController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 3/31/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "RUSingleton.h"
#import "TTSocketController.h"
#import "TTCurrency.h"

@interface TTGoxSocketController : TTSocketController

-(void)subscribeToChannelID:(NSString*)channelID;

-(void)subscribeToKeyID:(NSString*)channelID;

@end
