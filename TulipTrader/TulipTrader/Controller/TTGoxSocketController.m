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

@end

@implementation TTGoxSocketController

RU_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(TTGoxSocketController, sharedInstance);

#pragma mark Public Methods

-(void)write:(NSString *)utfString
{
    [_socketConn send:[utfString dataUsingEncoding:NSUTF8StringEncoding]];
}

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

-(id)parseSocketMessage:(id)message
{
    if (![message isKindOfClass:[NSString class]])
        [NSException raise:@"Bad Class of Message Object" format:RUStringWithFormat(@"Message callback from WebSocket was %@, should've been NSString"), NSStringFromClass([message class])];
    
    NSMutableString* mutableStringMessage = [NSMutableString stringWithString:(NSString *)message];
    
    unichar firstCharacter = [mutableStringMessage characterAtIndex:0];
    unichar lastCharacter = [mutableStringMessage characterAtIndex:mutableStringMessage.length - 1];
    
    if (![stringFromUnichar(firstCharacter) isEqualToString:kTTGoxFrameOpenNSString] && ![stringFromUnichar(lastCharacter)isEqualToString:kTTGoxFrameCloseNSString])
        [NSException raise:@"TTBadMessageFrameUnichar" format:@"Message frame open/close was bad"];
    
    [mutableStringMessage deleteCharactersInRange:NSMakeRange(0, 1)]; // Delete opening curly
    [mutableStringMessage deleteCharactersInRange:NSMakeRange(mutableStringMessage.length - 1, 1)]; // Delete closing curly
    
    NSMutableDictionary* keyValues = [NSMutableDictionary dictionary];
    
    NSArray* valueKeyComponentsArray = [mutableStringMessage componentsSeparatedByString:@","];
    [valueKeyComponentsArray enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        NSArray* keyValue = [obj componentsSeparatedByString:@":"];
        NSMutableArray* copyDestination = [NSMutableArray array];
        [keyValue enumerateObjectsUsingBlock:^(NSString* s, NSUInteger idx, BOOL *stop) {
            NSMutableString* mutableCopy = [s mutableCopy];
            [mutableCopy deleteCharactersInRange:NSMakeRange(0, 1)];
            [mutableCopy deleteCharactersInRange:NSMakeRange(mutableCopy.length - 1, 1)];
            [copyDestination insertObject:mutableCopy atIndex:idx];
        }];
        [keyValues setObject:[copyDestination objectAtIndex:1] forKey:[copyDestination objectAtIndex:0]];
    }];
    
    return keyValues;
}

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
    NSDictionary* responseDictionary = (NSDictionary*)[self parseSocketMessage:message];
    TTGoxSocketMessageType type = messageTypeFromDictionary(responseDictionary);
    switch (type) {
        case TTGoxSocketMessageTypeRemark:
            RUDLog(@"Remark");
            [_remarkDelegate shouldExamineResponseDictionary:responseDictionary ofMessageType:type];
            break;
            
        case TTGoxSocketMessageTypeSubscribe:
        case TTGoxSocketMessageTypeUnsubscribe:
            RUDLog(@"Subscribe");
            [_subscribeDelegate shouldExamineResponseDictionary:responseDictionary ofMessageType:type];
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
    else if ([operationString isEqualToString:kTTGoxOperationKeySubscribe])
        return TTGoxSocketMessageTypeSubscribe;
    else if ([operationString isEqualToString:kTTGoxOperationKeyUnsubscribe])
        return TTGoxSocketMessageTypeUnsubscribe;
    else if ([operationString isEqualToString:kTTGoxOperationKeyPrivate])
        return TTGoxSocketMessageTypePrivate;
    else if ([operationString isEqualToString:kTTGoxOperationKeyResult])
        return TTGoxSocketMessageTypeResult;
    else
        return TTGoxSocketMessageTypeNone;
}

@end
