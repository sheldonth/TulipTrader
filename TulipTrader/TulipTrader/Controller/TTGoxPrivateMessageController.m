//
//  TTGoxPrivateMessageController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/1/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTGoxPrivateMessageController.h"
#import "RUSingleton.h"
#import "RUConstants.h"

NSString* const kTTGoxDepthKey = @"depth";
NSString* const kTTGoxTickerKey = @"ticker";
NSString* const kTTGoxTradeKey = @"trade";

@implementation TTGoxPrivateMessageController

-(void)shouldExamineResponseDictionary:(NSDictionary *)dictionary ofMessageType:(TTGoxSocketMessageType)type
{
    RUDLog(@"%@",[dictionary objectForKey:@"private"]);
}

RU_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(TTGoxPrivateMessageController, sharedInstance);

@end
