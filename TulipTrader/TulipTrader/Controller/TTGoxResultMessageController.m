//
//  TTGoxResultMessageController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/1/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTGoxResultMessageController.h"
#import "RUSingleton.h"
#import "RUConstants.h"

@implementation TTGoxResultMessageController

-(void)shouldExamineResponseDictionary:(NSDictionary *)dictionary ofMessageType:(TTGoxSocketMessageType)type
{
    RUDLog(@"Result");
}

RU_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(TTGoxResultMessageController, sharedInstance);
@end