//
//  TTOperationsController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/1/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTOperationsController.h"
#import "RUConstants.h"
#import "TTGoxPrivateMessageController.h"
#import "TTGoxResultMessageController.h"
#import "TTOERatesController.h"

@interface TTOperationsController ()

@property(nonatomic, retain) TTGoxSocketController* socketController;
@property(nonatomic, retain) TTGoxPrivateMessageController* privateMessageController;
@property(nonatomic, retain) TTGoxResultMessageController* resultMessageController;
@property(nonatomic, retain) TTOERatesController* oeRatesController;
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
        _socketController = [TTGoxSocketController sharedInstance];
        
        [_socketController setRemarkDelegate:self];
        
        _privateMessageController = [TTGoxPrivateMessageController new];
        
        [_socketController setPrivateDelegate:_privateMessageController];
        
        _resultMessageController = [TTGoxResultMessageController new];
        
        [_socketController setResultDelegate:_resultMessageController];
        
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
