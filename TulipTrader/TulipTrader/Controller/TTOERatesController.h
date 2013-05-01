//
//  TTOERatesController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/29/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTGoxCurrency.h"

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

@interface TTOERatesController : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

-(void)reloadRates;

-(NSNumber*)priceInUSDBaseForCurrency:(TTGoxCurrency)currency;

-(NSNumber*)priceForCurrency:(TTGoxCurrency)currency inBaseCurrency:(TTGoxCurrency)baseCurrency;

@property(assign)id<TTOERatesControllerDelegate> delegate;

@end
