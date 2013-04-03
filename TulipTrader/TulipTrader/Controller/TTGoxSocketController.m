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

NSString* const kTTGoxWebSocketURL  = @"wss://websocket.mtgox.com/mtgox";
NSString* const kTTGoxSocketIOURL  = @"wss://socketio.mtgox.com/mtgox";

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
NSString* const kTTGoxSocketTickerChannelID  = @"d5f06780-30a8-4a48-a2f8-7ed181b4a13f";
NSString* const kTTGoxSocketDepthChannelID  = @"24e67e0d-1cad-4cc0-9e7a-f8523ef460fe";

#pragma mark public methods

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setRetries:0];
    }
    return self;
}

-(void)subscribe:(TTGoxSubscriptionChannel)channel
{
    NSString* channelID;
    
    switch (channel) {
        case TTGoxSubscriptionChannelTrades:
            channelID = kTTGoxSocketTradesChannelID;
            break;
        case TTGoxSubscriptionChannelTicker:
            channelID = kTTGoxSocketTickerChannelID;
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
    if (kTTUseWebSocketURL)
        _socketConn = [[SRWebSocket alloc]initWithURL:[NSURL URLWithString:kTTGoxWebSocketURL]];
    else
        _socketConn = [[SRWebSocket alloc]initWithURL:[NSURL URLWithString:kTTGoxSocketIOURL]];
    [_socketConn setDelegate:self];
    _retries++;
    [_socketConn open];
}

-(void)write:(NSString *)utfString
{
    [_socketConn send:[utfString dataUsingEncoding:NSUTF8StringEncoding]];
}

-(id)parseSocketMessage:(id)message
{
    if (![message isKindOfClass:[NSString class]])
        [NSException raise:@"Bad Class of Message Object" format:RUStringWithFormat(@"Message callback from WebSocket was %@, should've been NSString"), NSStringFromClass([message class])];
    
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
    [self subscribe:TTGoxSubscriptionChannelTicker];
}

-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    RUDLog(@"%@ Closed with code %li and reason %@ and is clean %i", webSocket, code, reason, wasClean);
    [self open];
}

-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
//    RUDLog(@"%@ %@ Message Recieved %@", webSocket, [message class], message);
    NSDictionary* responseDictionary = (NSDictionary*)[self parseSocketMessage:message];
    TTGoxSocketMessageType type = messageTypeFromDictionary(responseDictionary);
    switch (type) {
        case TTGoxSocketMessageTypeRemark:
            RUDLog(@"Remark");
            [_remarkDelegate shouldExamineResponseDictionary:responseDictionary ofMessageType:type];
            break;
            
        case TTGoxSocketMessageTypePrivate:
            RUDLog(@"Private");
            [_privateDelegate shouldExamineResponseDictionary:responseDictionary ofMessageType:type];
            break;
            
        case TTGoxSocketMessageTypeResult:
            RUDLog(@"Result");
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
    RUDLog(@"%@ %@ Failed With Error %@", webSocket, [webSocket class], error.localizedDescription);
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
