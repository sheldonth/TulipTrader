//
//  TTBlockChainSocketController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/15/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTBlockChainSocketController.h"
#import "RUConstants.h"

@implementation TTBlockChainSocketController

-(BOOL)usesWebsocketURL
{
    return YES;
}

-(NSString *)websocketURL
{
    return @"ws://ws.blockchain.info/inv";
}

-(NSString *)socketIOURL
{
    return @"";
}

-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    RUDLog(@"!");
}

@end
