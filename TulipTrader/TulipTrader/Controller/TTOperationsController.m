//
//  TTOperationsController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/1/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTOperationsController.h"
#import "RUConstants.h"

@interface TTOperationsController ()

@property(nonatomic, retain) TTGoxSocketController* socketController;

@end

@implementation TTOperationsController

-(void)shouldExamineResponseDictionary:(NSDictionary *)dictionary ofMessageType:(TTGoxSocketMessageType)type
{
    RUDLog(@"Remark %@", dictionary);
}

-(id)init
{
    self = [super init];
    if (self)
    {
        _socketController = [TTGoxSocketController sharedInstance];
        
        [_socketController setRemarkDelegate:self];
        
        [_socketController open];
    }
    return self;
}

@end
