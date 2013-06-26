//
//  TTSocketController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/21/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTSocketController.h"
#import "RUConstants.h"
#import "JSONKit.h"

NSString* const kTTWebsocketFrameOpenNSString = @"{";
NSString* const kTTWebsocketFrameCloseNSString = @"}";

@interface TTSocketController()

@property (nonatomic, strong) SRWebSocket* socketConn;
@property (nonatomic)NSInteger retries;

-(BOOL)usesWebsocketURL;
-(NSString *)websocketURL;
-(NSString *)socketIOURL;

@end

@implementation TTSocketController

-(BOOL)usesWebsocketURL
{
    RU_MUST_OVERRIDE
    return YES;
}

-(NSString *)websocketURL
{
    RU_MUST_OVERRIDE
    return nil;
}

-(NSString *)socketIOURL
{
    RU_MUST_OVERRIDE;
    return nil;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setRetries:0];
        [self setConnectionState:TTSocketConnectionStateNotConnected];
    }
    return self;
}

-(void)openWithCurrency:(TTCurrency)currency
{
    [self setCurrency:currency];
    _socketConn = nil;
    if (self.usesWebsocketURL)
        _socketConn = [[SRWebSocket alloc]initWithURL:[NSURL URLWithString:self.websocketURL]];
    else
        _socketConn = [[SRWebSocket alloc]initWithURL:[NSURL URLWithString:self.socketIOURL]];
    if (!_dispatchQueue)
        _dispatchQueue = dispatch_queue_create("ttSocketDelegateQueue1", NULL);
    [_socketConn setDelegate:self];
    [_socketConn setDelegateDispatchQueue:_dispatchQueue];
    _retries++;
    [self setConnectionState:TTSocketConnectionStateConnecting];
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
    
    if (![stringFromUnichar(firstCharacter) isEqualToString:kTTWebsocketFrameOpenNSString] && ![stringFromUnichar(lastCharacter)isEqualToString:kTTWebsocketFrameCloseNSString])
        [NSException raise:@"TTBadMessageFrameUnichar" format:@"Message frame open/close was bad"];
    
    NSDictionary* keyValues = [mutableStringMessage objectFromJSONString];
    
    return keyValues;
}

NSString* stringFromUnichar(unichar t)
{
    return RUStringWithFormat(@"%C", t);
}

#pragma mark SRWebSocketDelegate Methods

-(void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    [self setConnectionState:TTSocketConnectionStateConnected];
}

-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    RUDLog(@"%@ Closed with code %li and reason %@ and is clean %i", webSocket, code, reason, wasClean);
    [self setConnectionState:TTSocketConnectionStateNotConnected];
    [self openWithCurrency:self.currency];
}

-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{

}

-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    RUDLog(@"%li Reconnect Attempt", _retries);
    [self openWithCurrency:self.currency];
}

-(void)dealloc
{
    [_socketConn close];
}



@end
