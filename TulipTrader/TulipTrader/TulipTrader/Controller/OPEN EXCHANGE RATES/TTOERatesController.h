//
//  TTOERatesController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/29/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTCurrency.h"
#import "RUSingleton.h"

@protocol TTOERatesControllerDelegate <NSObject>

-(void)rateRefreshDidFinish;
-(void)rateRefreshDidFail;

@end

extern NSString* const OEApiKey;
extern NSString* const OEApiBaseURL;
extern NSString* const OEApiLatestURL;
extern NSString* const OEApiCurrenciesURL;
extern NSString* const OELastLoadedDateKey;
extern NSString* const OELastLoadedDataKey;

extern NSString* const OERatesLoadedNotificationString;

@interface TTOERatesController : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

-(void)reloadRates;

-(NSNumber*)priceInUSDBaseForCurrency:(TTCurrency)currency;

-(NSNumber*)priceForCurrency:(TTCurrency)currency inBaseCurrency:(TTCurrency)baseCurrency;

@property(assign)id<TTOERatesControllerDelegate> delegate;

RU_SYNTHESIZE_SINGLETON_DECLARATION_FOR_CLASS_WITH_ACCESSOR(TTOERatesController, sharedInstance);

@end
