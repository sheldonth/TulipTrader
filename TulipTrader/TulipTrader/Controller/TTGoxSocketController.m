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

static NSArray* currencies;
static NSDictionary* currencyUsagePairs;

static NSMutableString* kTTGoxWebSocketURL;
static NSMutableString* kTTGoxSocketIOURL;

#pragma mark public methods

+(void)initialize
{
    currencies = @[@"USD", @"AUD", @"CAD", @"CHF", @"CNY", @"DKK", @"EUR", @"GBP", @"HKD", @"JPY", @"NZD", @"PLN", @"RUB", @"SEK", @"SGD", @"THB"];
    currencyUsagePairs = @{@"USD": @(1),
                           @"AUD": @(0),
                           @"CAD": @(0),
                           @"CHF": @(0),
                           @"CNY": @(0),
                           @"DKK": @(0),
                           @"EUR": @(0),
                           @"GBP": @(0),
                           @"HKD": @(0),
                           @"JPY": @(0),
                           @"NZD": @(0),
                           @"PLN": @(0),
                           @"RUB": @(0),
                           @"SEK": @(0),
                           @"SGD": @(0),
                           @"THB": @(0),};
    kTTGoxWebSocketURL = [NSMutableString stringWithString:@"wss://websocket.mtgox.com/mtgox?Currency="];
    kTTGoxSocketIOURL = [NSMutableString stringWithString:@"wss://socketio.mtgox.com/mtgox?Currency="];
    [[currencyUsagePairs allKeys] enumerateObjectsUsingBlock:^(NSString* key, NSUInteger idx, BOOL *stop) {
        if ([[currencyUsagePairs objectForKey:key]isEqualToNumber:@(1)])
            [kTTGoxWebSocketURL appendFormat:@"%@,", key];
    }];
}

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
    [self subscribe:TTGoxSubscriptionChannelDepth];
    [self subscribe:TTGoxSubscriptionChannelTrades];
}

-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    RUDLog(@"%@ Closed with code %li and reason %@ and is clean %i", webSocket, code, reason, wasClean);
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
