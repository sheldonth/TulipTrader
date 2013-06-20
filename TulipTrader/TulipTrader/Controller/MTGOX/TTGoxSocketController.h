//
//  TTGoxSocketController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 3/31/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
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

-(void)subscribeToChannelID:(NSString*)channelID;

-(void)subscribeToKeyID:(NSString*)channelID;

-(void)open;

@property(nonatomic, strong) dispatch_queue_t dispatchQueue;

@property(nonatomic)TTGoxSocketConnectionState isConnected;

@property(nonatomic, retain)id<TTGoxSocketControllerMessageDelegate> messageDelegate;

@end
