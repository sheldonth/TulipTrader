//
//  TTOperationsController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/1/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTOperationsController.h"
#import "RUConstants.h"


@interface TTOperationsController ()

@property(nonatomic, retain) NSTimer* oeRatesTimer;

@end

@implementation TTOperationsController

-(void)shouldExamineResponseDictionary:(NSDictionary *)dictionary ofMessageType:(TTGoxSocketMessageType)type
{
    RUDLog(@"Remark Held: %@", dictionary);
}

-(id)init
{
    self = [super init];
    if (self)
    {
        _socketController = [TTGoxSocketController new];
        
//        [_socketController setRemarkDelegate:self];
        
        _privateMessageController = [TTGoxPrivateMessageController new];
        
//        [_socketController setPrivateDelegate:_privateMessageController];
        
        _resultMessageController = [TTGoxResultMessageController new];
        
//        [_socketController setResultDelegate:_resultMessageController];
        
        [_socketController open];
        
        _oeRatesController = [TTOERatesController sharedInstance];
        
        [_oeRatesController reloadRates];
        
        [self setOeRatesTimer:[NSTimer scheduledTimerWithTimeInterval:600 target:_oeRatesController selector:@selector(reloadRates) userInfo:nil repeats:YES]];
    }
    return self;
}

-(void)dealloc
{
    [self.oeRatesTimer invalidate];
    [self setOeRatesTimer:nil];
}

@end
