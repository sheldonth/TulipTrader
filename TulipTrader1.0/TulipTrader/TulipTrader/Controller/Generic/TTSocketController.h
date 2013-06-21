//
//  TTSocketController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/21/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
#import "TTCurrency.h"
#import "TTDepthOrder.h"

@class TTSocketController;
@class TTTrade;
@class TTTicker;


@protocol TTSocketControllerDelegate <NSObject>

-(void)socketController:(TTSocketController*)socketController tradeObserved:(TTTrade*)theTrade;
-(void)socketController:(TTSocketController*)socketController tickerObserved:(TTTicker*)theTicker;
-(void)socketController:(TTSocketController*)socketController orderBookDeltaObserved:(TTDepthOrder*)orderBookDelta;

@end

typedef enum{
    TTSocketConnectionStateNone = 0,
    TTSocketConnectionStateNotConnected,
    TTSocketConnectionStateConnecting,
    TTSocketConnectionStateConnected,
    TTSocketConnectionStateFailed
}TTSocketConnectionState;

@interface TTSocketController : NSObject <SRWebSocketDelegate>

@property(nonatomic)TTSocketConnectionState connectionState;
@property(nonatomic, strong) dispatch_queue_t dispatchQueue;
@property(nonatomic)TTCurrency currency;

@property(nonatomic, weak)id <TTSocketControllerDelegate> delegate;

-(void)open;
-(void)write:(NSString*)utfString;

-(NSString*)websocketURL;
-(NSString*)socketIOURL;

-(id)parseSocketMessage:(id)message;

@end
