//
//  TTGoxSocketController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 3/31/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTGoxSocketController.h"
#import "RUConstants.h"

NSString* const kTTGoxWebSocketURL  = @"websocket.mtgox.com";
NSString* const kTTGoxSocketIOURL  = @"socketio.mtgox.com";

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

}

#pragma mark Private Methods

#pragma mark SRWebSocketDelegate Methods

-(void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    
}

-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    
}

-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    
}

-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    RUDLog(@"Websocked Failed: %@")
}

@end
