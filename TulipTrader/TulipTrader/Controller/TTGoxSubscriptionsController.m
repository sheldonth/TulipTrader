//
//  TTGoxSubscriptionsController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 3/31/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTGoxSubscriptionsController.h"
#import "RUConstants.h"
#import "JSONKit.h"

NSString* const kTTGoxChannelKey = @"channel";

@implementation TTGoxSubscriptionsController

#pragma mark private methods

-(void)doSubscribeWithDictionary:(NSDictionary*)dictionary
{
    TTGoxSubscriptionChannel channel = channelForId([dictionary objectForKey:kTTGoxChannelKey]);
    [_channels addObject:@(channel)];
    RUDLog(@"Channel %i subscribed", channel);
}

-(void)doUnsubscribeWithDictionary:(NSDictionary*)dictionary
{
    TTGoxSubscriptionChannel channel = channelForId([dictionary objectForKey:kTTGoxChannelKey]);
    [_channels removeObject:@(channel)];
    RUDLog(@"Channel %i unsubscribed", channel);
}

#pragma mark TTGoxSocketControllerMessageDelegate

-(void)shouldExamineResponseDictionary:(NSDictionary *)dictionary ofMessageType:(TTGoxSocketMessageType)type
{
    switch (type) {
        case TTGoxSocketMessageTypeSubscribe:
            [self doSubscribeWithDictionary:dictionary];
            break;
            
        case TTGoxSocketMessageTypeUnsubscribe:
            [self doUnsubscribeWithDictionary:dictionary];
            break;
            
        case TTGoxSocketMessageTypeNone:
        case TTGoxSocketMessageTypeRemark:
        case TTGoxSocketMessageTypePrivate:
        case TTGoxSocketMessageTypeResult:
            [NSException raise:@"Subscriptions Controller" format:@"Got a message of a type it doesn't handle"];
    }
}

#pragma mark - Default Methods

-(id)init
{
    self = [super init];
    if (self)
    {
        _socketController = [TTGoxSocketController sharedInstance];
        [_socketController setSubscribeDelegate:self];
        
        _channels = [NSMutableArray array];
    }
    return self;
}

#pragma mark - C Methods

TTGoxSubscriptionChannel channelForId(NSString* idNum)
{
    if ([idNum isEqualToString:kTTGoxSocketTradesChannelID])
        return TTGoxSubscriptionChannelTrades;
    else if ([idNum isEqualToString:kTTGoxSocketTickerChannelID])
        return TTGoxSubscriptionChannelTicker;
    else if ([idNum isEqualToString:kTTGoxSocketDepthChannelID])
        return TTGoxSubscriptionChannelDepth;
    else return TTGoxSubscriptionChannelNone;
}

@end
