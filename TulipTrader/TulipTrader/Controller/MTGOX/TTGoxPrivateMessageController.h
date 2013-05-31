//
//  TTGoxPrivateMessageController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/1/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUSingleton.h"
#import "TTGoxSocketController.h"
#import "TTGoxCurrency.h"
#import "Trade.h"

@protocol TTGoxPrivateMessageControllerLagDelegate <NSObject>

-(void)lagObserved:(NSDictionary*)lagDict;

@end

@protocol TTGoxPrivateMessageControllerTradesDelegate <NSObject>

-(void)tradeOccuredForCurrency:(TTGoxCurrency)currency tradeData:(Trade*)trade;

@end

@interface TTGoxPrivateMessageController : NSObject <TTGoxSocketControllerMessageDelegate>

@property(nonatomic) id<TTGoxPrivateMessageControllerLagDelegate>lagDelegate;
@property(nonatomic) id<TTGoxPrivateMessageControllerTradesDelegate>tradeDelegate;

extern NSString* const TTCurrencyUpdateNotificationString;

RU_SYNTHESIZE_SINGLETON_DECLARATION_FOR_CLASS_WITH_ACCESSOR(TTGoxPrivateMessageController, sharedInstance);

@end
