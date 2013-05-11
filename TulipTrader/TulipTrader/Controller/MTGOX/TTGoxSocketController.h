//
//  TTGoxSocketController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 3/31/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "RUSingleton.h"
#import "SRWebSocket.h"
#import "TTGoxCurrency.h"

typedef enum{
    TTGoxSocketMessageTypeNone = 0,
    TTGoxSocketMessageTypeRemark,
    TTGoxSocketMessageTypePrivate,
    TTGoxSocketMessageTypeResult
}TTGoxSocketMessageType;

typedef enum{
    TTGoxSubscriptionChannelNone = 0,
    TTGoxSubscriptionChannelTrades,
    TTGoxSubscriptionChannelTicker,
    TTGoxSubscriptionChannelDepth
}TTGoxSubscriptionChannel;

typedef enum{
    TTGoxSocketConnectionStateNone = 0,
    TTGoxSocketConnectionStateNotConnected,
    TTGoxSocketConnectionStateConnecting,
    TTGoxSocketConnectionStateConnected,
    TTGoxSocketConnectionStateFailed
}TTGoxSocketConnectionState;

@protocol TTGoxSocketControllerMessageDelegate <NSObject>

-(void)shouldExamineResponseDictionary:(NSDictionary*)dictionary ofMessageType:(TTGoxSocketMessageType)type;

@end


@interface TTGoxSocketController : NSObject <SRWebSocketDelegate>

-(void)subscribe:(TTGoxSubscriptionChannel)channel;

-(void)open;

@property (assign) id <TTGoxSocketControllerMessageDelegate> subscribeDelegate;
@property (assign) id <TTGoxSocketControllerMessageDelegate> remarkDelegate;
@property (assign) id <TTGoxSocketControllerMessageDelegate> privateDelegate;
@property (assign) id <TTGoxSocketControllerMessageDelegate> resultDelegate;

@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

@property (nonatomic)TTGoxSocketConnectionState isConnected;

RU_SYNTHESIZE_SINGLETON_DECLARATION_FOR_CLASS_WITH_ACCESSOR(TTGoxSocketController, sharedInstance);

@end
