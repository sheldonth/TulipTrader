
//
//  TTGoxSocketController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 3/31/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTGoxSocketController.h"
#import "RUConstants.h"
#import "JSONKit.h"
#import "TTGoxHTTPController.h"
#import "RUClassOrNilUtil.h"
#import "TTTicker.h"
#import "TTDepthOrder.h"

typedef enum{
    TTGoxSocketMessageTypeNone = 0,
    TTGoxSocketMessageTypeRemark,
    TTGoxSocketMessageTypePrivate,
    TTGoxSocketMessageTypeResult
}TTGoxSocketMessageType;

typedef enum{
    kTTGoxMarketNone = 0,
    kTTGoxMarketDepth = 1,
    kTTGoxMarketTrade = 2,
    kTTGoxMarketTicker = 3,
    kTTGoxMarketLag = 4
}kTTGoxMarketDataType;

NSString* const kTTGoxOperationKey = @"op";

NSString* const kTTGoxOperationKeySubscribe = @"subscribe";//	 Notification that the user is subscribed to a channel
NSString* const kTTGoxOperationKeyUnsubscribe = @"unsubscribe";//	 Messages will no longer arrive over the channel
NSString* const kTTGoxOperationKeyRemark = @"remark";//	 A server message, usually a warning
NSString* const kTTGoxOperationKeyPrivate = @"private";//	 The operation for depth, trade, and ticker messages
NSString* const kTTGoxOperationKeyResult = @"result";//    The response for op:call operations

NSString* const kTTGoxDepthKey = @"depth";
NSString* const kTTGoxTickerKey = @"ticker";
NSString* const kTTGoxTradeKey = @"trade";
NSString* const kTTGoxLagKey = @"lag";

#define kTTSubscribeToLag 0

@implementation TTGoxSocketController

#pragma mark Public Methods

NSString* const kTTGoxSocketTradesChannelID  = @"dbf1dee9-4f2e-4a08-8cb7-748919a71b21";

NSString* const kTTGoxSocketTickerUSDChannelID  = @"d5f06780-30a8-4a48-a2f8-7ed181b4a13f";
NSString* const kTTGoxSocketDepthUSDChannelID  = @"24e67e0d-1cad-4cc0-9e7a-f8523ef460fe";

NSString* const kTTGoxSocketTickerAUDChannelID = @"eb6aaa11-99d0-4f64-9e8c-1140872a423d";
NSString* const kTTGoxSocketDepthAUDChannelID = @"296ee352-dd5d-46f3-9bea-5e39dede2005";

NSString* const kTTGoxSocketTickerCADChannelID = @"10720792-084d-45ba-92e3-cf44d9477775";
NSString* const kTTGoxSocketDepthCADChannelID = @"5b234cc3-a7c1-47ce-854f-27aee4cdbda5";

NSString* const kTTGoxSocketDepthChannelID  = @"24e67e0d-1cad-4cc0-9e7a-f8523ef460fe";

-(NSString *)websocketURL
{
    return RUStringWithFormat(@"wss://websocket.mtgox.com/mtgox?Currency=%@", stringFromCurrency(self.currency));
}

-(NSString *)socketIOURL
{
    return RUStringWithFormat(@"wss://socketio.mtgox.com/mtgox?Currency=%@", stringFromCurrency(self.currency));
}

-(void)subscribeToChannelID:(NSString*)channelID
{
    NSDictionary* d = @{@"channel" : channelID, @"op" : @"mtgox.subscribe"};
    
    [self write:[d JSONString]];
}

-(void)subscribeToKeyID:(NSString*)channelID
{
    NSDictionary* d = @{@"key" : channelID, @"op" : @"mtgox.subscribe"};
    
    [self write:[d JSONString]];
}

-(BOOL)usesWebsocketURL
{
    return YES;
}

-(void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    [super webSocketDidOpen:webSocket];
    if (kTTSubscribeToLag)
        [self subscribeToChannelID:@"trade.lag"];
//    [[TTGoxHTTPController sharedInstance]getAccountWebSocketKeyWithCompletion:^(NSString *accountKey) {
//        [self subscribeToKeyID:accountKey];
//    } failBlock:^(NSError *e) {
//        [TTAPIControlBoxView publishCommand:@"Account websocket key request failed. Run 'privKey' to retry."];
//    }];
}

-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSDictionary* responseDictionary = (NSDictionary*)[super parseSocketMessage:message];
    TTGoxSocketMessageType type = messageTypeFromDictionary(responseDictionary);
    switch (type) {
        case TTGoxSocketMessageTypeRemark:
            RUDLog(@"TTGoxSocketMessageTypeRemark");
            break;
            
        case TTGoxSocketMessageTypePrivate:
        {
            kTTGoxMarketDataType marketDataType = TTGoxMarketDataType(kRUStringOrNil([responseDictionary objectForKey:@"private"]));
            switch (marketDataType) {
                case kTTGoxMarketDepth:
                {
                    TTDepthOrder* depthOrder = [TTDepthOrder newDepthOrderFromGoxWebsocketDictionary:kRUDictionaryOrNil([responseDictionary objectForKey:@"depth"])];
                    [self.delegate socketController:self orderBookDeltaObserved:depthOrder];
                    break;
                }
                case kTTGoxMarketLag:
                {
                    RUDLog(@"kTTGoxMarketLag");
                    break;
                }
                    
                case kTTGoxMarketTicker:
                {
                    TTTicker* ticker = [TTTicker newTickerFromDictionary:responseDictionary];
                    [self.delegate socketController:self tickerObserved:ticker];
                    break;
                }
                case kTTGoxMarketTrade:
                {
                    
                    break;
                }
                case kTTGoxMarketNone:
                    RUDLog(@"kTTGoxMarketNone");
                    break;
                    
                default:
                    break;
            }
            break;
        }
            
            
        case TTGoxSocketMessageTypeResult:
            RUDLog(@"TTGoxSocketMessageTypeResult");
            break;
            
        case TTGoxSocketMessageTypeNone:
            [NSException raise:@"Socket Message Type" format:@"Cannot have socket message type none"];
            
        default:
            break;
    }
    [super webSocket:webSocket didReceiveMessage:message];
}

TTGoxSocketMessageType messageTypeFromDictionary(NSDictionary* dictionary)
{
    NSString* operationString = [dictionary objectForKey:kTTGoxOperationKey];
    if ([operationString isEqualToString:kTTGoxOperationKeyRemark])
        return TTGoxSocketMessageTypeRemark;
    else if ([operationString isEqualToString:kTTGoxOperationKeyPrivate])
        return TTGoxSocketMessageTypePrivate;
    else if ([operationString isEqualToString:kTTGoxOperationKeyResult])
        return TTGoxSocketMessageTypeResult;
    else
        return TTGoxSocketMessageTypeNone;
}

kTTGoxMarketDataType TTGoxMarketDataType(NSString* typeString)
{
    if ([typeString isEqualToString:kTTGoxDepthKey])
        return kTTGoxMarketDepth;
    else if ([typeString isEqualToString:kTTGoxTickerKey])
        return kTTGoxMarketTicker;
    else if ([typeString isEqualToString:kTTGoxTradeKey])
        return kTTGoxMarketTrade;
    else if ([typeString isEqualToString:kTTGoxLagKey])
        return kTTGoxMarketLag;
    else
        return kTTGoxMarketNone;
}


@end
