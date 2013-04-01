//
//  TTGoxSocketController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 3/31/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "RUSingleton.h"
#import "SRWebSocket.h"

typedef enum{
    TTGoxSocketMessageTypeNone = 0,
    TTGoxSocketMessageTypeRemark = 1,
    TTGoxSocketMessageTypeSubscribe = 2,
    TTGoxSocketMessageTypeUnsubscribe = 3,
    TTGoxSocketMessageTypePrivate = 4,
    TTGoxSocketMessageTypeResult = 5
}TTGoxSocketMessageType;

@protocol TTGoxSocketControllerMessageDelegate <NSObject>

-(void)shouldExamineResponseDictionary:(NSDictionary*)dictionary ofMessageType:(TTGoxSocketMessageType)type;

@end


@interface TTGoxSocketController : NSObject <SRWebSocketDelegate>

-(void)open;
-(void)write:(NSString*)utfString;

@property (assign) id <TTGoxSocketControllerMessageDelegate> subscribeDelegate;
@property (assign) id <TTGoxSocketControllerMessageDelegate> remarkDelegate;
@property (assign) id <TTGoxSocketControllerMessageDelegate> privateDelegate;
@property (assign) id <TTGoxSocketControllerMessageDelegate> resultDelegate;

RU_SYNTHESIZE_SINGLETON_DECLARATION_FOR_CLASS_WITH_ACCESSOR(TTGoxSocketController, sharedInstance);

@end
