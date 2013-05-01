//
//  TTGoxSocketController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 3/31/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTGoxSocketController.h"
#import "RUConstants.h"
#import "JSONKit.h"
#import "TTGoxCurrencyController.h"

NSString* const kTTGoxFrameOpenNSString = @"{";
NSString* const kTTGoxFrameCloseNSString = @"}";

NSString* const kTTGoxOperationKey = @"op";

NSString* const kTTGoxOperationKeySubscribe = @"subscribe";//	 Notification that the user is subscribed to a channel
NSString* const kTTGoxOperationKeyUnsubscribe = @"unsubscribe";//	 Messages will no longer arrive over the channel
NSString* const kTTGoxOperationKeyRemark = @"remark";//	 A server message, usually a warning
NSString* const kTTGoxOperationKeyPrivate = @"private";//	 The operation for depth, trade, and ticker messages
NSString* const kTTGoxOperationKeyResult = @"result";//    The response for op:call operations

#define kTTUseWebSocketURL 1

@interface TTGoxSocketController ()

@property (nonatomic, strong) SRWebSocket* socketConn;
@property (nonatomic)NSInteger retries;

-(void)open;
-(void)write:(NSString*)utfString;

@end

@implementation TTGoxSocketController

RU_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(TTGoxSocketController, sharedInstance);

#pragma mark Public Methods

NSString* const kTTGoxSocketTradesChannelID  = @"dbf1dee9-4f2e-4a08-8cb7-748919a71b21";

NSString* const kTTGoxSocketTickerUSDChannelID  = @"d5f06780-30a8-4a48-a2f8-7ed181b4a13f";
NSString* const kTTGoxSocketDepthUSDChannelID  = @"24e67e0d-1cad-4cc0-9e7a-f8523ef460fe";

NSString* const kTTGoxSocketTickerAUDChannelID = @"eb6aaa11-99d0-4f64-9e8c-1140872a423d";
NSString* const kTTGoxSocketDepthAUDChannelID = @"296ee352-dd5d-46f3-9bea-5e39dede2005";

NSString* const kTTGoxSocketTickerCADChannelID = @"10720792-084d-45ba-92e3-cf44d9477775";
NSString* const kTTGoxSocketDepthCADChannelID = @"5b234cc3-a7c1-47ce-854f-27aee4cdbda5";

NSString* const kTTGoxSocketDepthChannelID  = @"24e67e0d-1cad-4cc0-9e7a-f8523ef460fe";

static NSMutableString* kTTGoxWebSocketURL;
static NSMutableString* kTTGoxSocketIOURL;

#pragma mark public methods

+(void)initialize
{
    NSDictionary* currencyUsageDict = [[TTGoxCurrencyController sharedInstance] currencyUsagePairs];
    
    kTTGoxWebSocketURL = [NSMutableString stringWithString:@"wss://websocket.mtgox.com/mtgox?Currency="];
    kTTGoxSocketIOURL = [NSMutableString stringWithString:@"wss://socketio.mtgox.com/mtgox?Currency="];
    [[currencyUsageDict allKeys] enumerateObjectsUsingBlock:^(NSString* key, NSUInteger idx, BOOL *stop) {
        if ([[currencyUsageDict objectForKey:key]isEqualToNumber:@(1)])
            [kTTGoxWebSocketURL appendFormat:@"%@,", key];
            return;
    }];
}

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setRetries:0];
        [self setIsConnected:TTGoxSocketConnectionStateNotConnected];
    }
    return self;
}

-(void)subscribeToChannelID:(NSString*)channelID
{
//    NSDictionary* d = @{@"channel" : channelID, @"op" : @"subscribe"};
    NSDictionary* d = @{@"channel" : channelID, @"op" : @"mtgox.subscribe"};
    
    [self write:[d JSONString]];
}

-(void)subscribe:(TTGoxSubscriptionChannel)channel
{
    NSString* channelID;
    
    switch (channel) {
        case TTGoxSubscriptionChannelTrades:
            channelID = kTTGoxSocketTradesChannelID;
            break;
        case TTGoxSubscriptionChannelTicker:
//            channelID = kTTGoxSocketTickerChannelID;
            break;
        case TTGoxSubscriptionChannelDepth:
            channelID = kTTGoxSocketDepthChannelID;
            break;
            
        default:
            break;
    }
    
    NSDictionary* d = @{@"channel" : channelID, @"op" : @"subscribe"};
    
    [self write:[d JSONString]];
}

#pragma mark Private Methods
-(void)open
{
    _socketConn = nil;
    if (kTTUseWebSocketURL)
        _socketConn = [[SRWebSocket alloc]initWithURL:[NSURL URLWithString:kTTGoxWebSocketURL]];
    else
        _socketConn = [[SRWebSocket alloc]initWithURL:[NSURL URLWithString:kTTGoxSocketIOURL]];
    if (!_dispatchQueue)
        _dispatchQueue = dispatch_queue_create("ttSocketDelegateQueue1", NULL);
    [_socketConn setDelegate:self];
    [_socketConn setDelegateDispatchQueue:_dispatchQueue];
    _retries++;
    [self setIsConnected:TTGoxSocketConnectionStateConnecting];
    [_socketConn open];
}

-(void)write:(NSString *)utfString
{
    [_socketConn send:[utfString dataUsingEncoding:NSUTF8StringEncoding]];
}

-(id)parseSocketMessage:(id)message
{
    if (![message isKindOfClass:[NSString class]])
        [NSException raise:@"Bad Class of Message Object" format:@"Message callback from WebSocket was %@, should've been NSString", [message class]];
    
    NSMutableString* mutableStringMessage = [NSMutableString stringWithString:(NSString *)message];
    
    unichar firstCharacter = [mutableStringMessage characterAtIndex:0];
    unichar lastCharacter = [mutableStringMessage characterAtIndex:mutableStringMessage.length - 1];
    
    if (![stringFromUnichar(firstCharacter) isEqualToString:kTTGoxFrameOpenNSString] && ![stringFromUnichar(lastCharacter)isEqualToString:kTTGoxFrameCloseNSString])
        [NSException raise:@"TTBadMessageFrameUnichar" format:@"Message frame open/close was bad"];

    NSDictionary* keyValues = [mutableStringMessage objectFromJSONString];
    
    return keyValues;
}

#pragma mark SRWebSocketDelegate Methods

-(void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    RUDLog(@"%@ did open", webSocket);
    [self setIsConnected:TTGoxSocketConnectionStateConnected];
    
    [self subscribeToChannelID:@"ticker.BTCUSD"];
    [self subscribeToChannelID:@"ticker.BTCEUR"];
    [self subscribeToChannelID:@"ticker.BTCCAD"];
    [self subscribeToChannelID:@"ticker.BTCCHF"];
//    [self subscribeToChannelID:@"ticker.BTCCNY"];
//    [self subscribeToChannelID:@"ticker.BTCDKK"];
//    [self subscribeToChannelID:@"ticker.BTCGBP"];
//    [self subscribeToChannelID:@"ticker.BTCHKD"];
//    [self subscribeToChannelID:@"ticker.BTCJPY"];
//    [self subscribeToChannelID:@"ticker.BTCNZD"];
//    [self subscribeToChannelID:@"ticker.BTCPLN"];
//    [self subscribeToChannelID:@"ticker.BTCRUB"];
//    [self subscribeToChannelID:@"ticker.BTCSEK"];
//    [self subscribeToChannelID:@"ticker.BTCSGD"];
//    [self subscribeToChannelID:@"ticker.BTCTHB"];
//    [self subscribeToChannelID:@"ticker.BTCAUD"];
}

-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    RUDLog(@"%@ Closed with code %li and reason %@ and is clean %i", webSocket, code, reason, wasClean);
    [self setIsConnected:TTGoxSocketConnectionStateNotConnected];
    [self open];
}

-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSDictionary* responseDictionary = (NSDictionary*)[self parseSocketMessage:message];
    TTGoxSocketMessageType type = messageTypeFromDictionary(responseDictionary);
    switch (type) {
        case TTGoxSocketMessageTypeRemark:
            if (_remarkDelegate && [_remarkDelegate respondsToSelector:@selector(shouldExamineResponseDictionary:ofMessageType:)])
                [_remarkDelegate shouldExamineResponseDictionary:responseDictionary ofMessageType:type];
            break;
            
        case TTGoxSocketMessageTypePrivate:
            if (_privateDelegate && [_privateDelegate respondsToSelector:@selector(shouldExamineResponseDictionary:ofMessageType:)])
                [_privateDelegate shouldExamineResponseDictionary:responseDictionary ofMessageType:type];
            break;
            
        case TTGoxSocketMessageTypeResult:
            if (_resultDelegate && [_resultDelegate respondsToSelector:@selector(shouldExamineResponseDictionary:ofMessageType:)])
                [_resultDelegate shouldExamineResponseDictionary:responseDictionary ofMessageType:type];
            break;
            
        case TTGoxSocketMessageTypeNone:
            [NSException raise:@"Socket Message Type" format:@"Cannot have socket message type none"];
            
        default:
            break;
    }
}

-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    RUDLog(@"%li Reconnect Attempt", _retries);
    [self open];
}

#pragma mark - C methods

NSString* stringFromUnichar(unichar t)
{
    return RUStringWithFormat(@"%C", t);
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

-(void)dealloc
{
    [_socketConn close];
}
@end
