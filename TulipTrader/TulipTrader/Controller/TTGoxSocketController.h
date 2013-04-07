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
    TTGoxCurrencyNone = 0,
    TTGoxCurrencyBTC, // Bitcoin
    TTGoxCurrencyUSD, // US Dollar
    TTGoxCurrencyAUD, // Australian Dollar
    TTGoxCurrencyCAD, // Canadian Dollar
    TTGoxCurrencyCHF, // Swiss Franc
    TTGoxCurrencyCNY, // Chinese Renminbi
    TTGoxCurrencyDKK, // Danish Krone
    TTGoxCurrencyEUR, // Euro
    TTGoxCurrencyGBP, // Great British Pound
    TTGoxCurrencyHKD, // Hong Kong Dollar
    TTGoxCurrencyJPY, // Japanese Yen
    TTGoxCurrencyNZD, // New Zealand Dollar
    TTGoxCurrencyPLN, // Polish Zloty
    TTGoxCurrencyRUB, // Russian Ruble
    TTGoxCurrencySEK, // Swedish Krona
    TTGoxCurrencySGD, // Singapore Dollar
    TTGoxCurrencyTHB  // Thai Bhat
}TTGoxCurrency;

typedef enum{
    TTGoxSocketMessageTypeNone = 0,
    TTGoxSocketMessageTypeRemark,
    TTGoxSocketMessageTypePrivate,
    TTGoxSocketMessageTypeResult
}TTGoxSocketMessageType;

typedef enum{
    TTGoxSubscriptionChannelNone = 0,
    TTGoxSubscriptionChannelTrades,
    TTGoxSubscriptionChannelTicker,
    TTGoxSubscriptionChannelDepth
}TTGoxSubscriptionChannel;

@protocol TTGoxSocketControllerMessageDelegate <NSObject>

-(void)shouldExamineResponseDictionary:(NSDictionary*)dictionary ofMessageType:(TTGoxSocketMessageType)type;

@end


@interface TTGoxSocketController : NSObject <SRWebSocketDelegate>

-(void)subscribe:(TTGoxSubscriptionChannel)channel;

-(void)open;

@property (assign) id <TTGoxSocketControllerMessageDelegate> subscribeDelegate;
@property (assign) id <TTGoxSocketControllerMessageDelegate> remarkDelegate;
@property (assign) id <TTGoxSocketControllerMessageDelegate> privateDelegate;
@property (assign) id <TTGoxSocketControllerMessageDelegate> resultDelegate;

@property (nonatomic, retain)NSNumber* isConnected;

RU_SYNTHESIZE_SINGLETON_DECLARATION_FOR_CLASS_WITH_ACCESSOR(TTGoxSocketController, sharedInstance);

@end
