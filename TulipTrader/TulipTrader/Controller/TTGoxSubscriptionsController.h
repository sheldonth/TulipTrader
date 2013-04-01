//
//  TTGoxSubscriptionsController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 3/31/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TTGoxSocketController.h"

typedef enum{
    TTGoxSubscriptionChannelNone = 0,
    TTGoxSubscriptionChannelTrades,
    TTGoxSubscriptionChannelTicker,
    TTGoxSubscriptionChannelDepth
}TTGoxSubscriptionChannel;

@interface TTGoxSubscriptionsController : NSObject <TTGoxSocketControllerMessageDelegate>

-(void)subscribe:(TTGoxSubscriptionChannel)channel;

@property(nonatomic, retain)TTGoxSocketController* socketController;
@property(nonatomic, readonly)NSMutableArray* channels;

@end
