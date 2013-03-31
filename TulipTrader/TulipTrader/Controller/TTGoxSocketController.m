//
//  TTGoxSocketController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 3/31/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTGoxSocketController.h"
#import "RUConstants.h"

NSString* const kTTGoxWebSocketURL  = @"wss://websocket.mtgox.com";
NSString* const kTTGoxSocketIOURL  = @"wss://socketio.mtgox.com";

#define kTTUseWebSocketURL 1

@interface TTGoxSocketController ()
{
    
}

@property (nonatomic, strong) SRWebSocket* socketConn;

@end

@implementation TTGoxSocketController

RU_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(TTGoxSocketController, sharedInstance);

#pragma mark Public Methods

-(void)open
{
    if (!_socketConn)
    {
        if (kTTUseWebSocketURL)
            _socketConn = [[SRWebSocket alloc]initWithURL:[NSURL URLWithString:kTTGoxWebSocketURL]];
        else
            _socketConn = [[SRWebSocket alloc]initWithURL:[NSURL URLWithString:kTTGoxSocketIOURL]];
    }
    [_socketConn setDelegate:self];
    [_socketConn open];
}

#pragma mark Private Methods

#pragma mark SRWebSocketDelegate Methods

-(void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    RUDLog(@"%@ did open", webSocket);
}

-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    RUDLog(@"%@ Closed with code %li and reason %@ and is clean %i", webSocket, code, reason, wasClean);
}

-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    RUDLog(@"%@ %@ Message Recieved %@", webSocket, [message class], message);
}

-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    RUDLog(@"%@ %@ Failed With Error %@", webSocket, [webSocket class], error.localizedDescription);
}

@end
