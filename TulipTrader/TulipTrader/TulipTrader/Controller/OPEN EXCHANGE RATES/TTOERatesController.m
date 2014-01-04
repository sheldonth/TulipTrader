//
//  TTOERatesController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/29/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTOERatesController.h"
#import "TTCurrency.h"
#import "RUConstants.h"
#import "JSONKit.h"

@interface TTOERatesController ()

@property(nonatomic, retain)NSDictionary* currencyValues;
@property(nonatomic, retain)NSURLConnection* urlConnection;
@property(nonatomic, retain)NSMutableData* requestData;

-(NSDate*)lastLoadedDate;
-(void)setLastLoadedDate:(NSDate*)d;

-(NSDictionary*)lastLoadedData;
-(void)setLastLoadedData:(NSDictionary*)data;

@end

NSString* const OEApiKey = @"033a8ac44e444a5d9ea04fe75f24f5ce";
NSString* const OEApiBaseURL = @"http://openexchangerates.org/api/";
NSString* const OEApiLatestURL = @"latest.json";
NSString* const OEApiCurrenciesURL = @"currencies.json";
NSString* const OELastLoadedDateKey = @"OELastLoadedDate";
NSString* const OELastLoadedDataKey = @"OELastLoadedData";

NSString* const OERatesLoadedNotificationString = @"TTOERatesDidReload";

@implementation TTOERatesController

RU_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(TTOERatesController, sharedInstance);

#pragma mark - public methods

/*
 For example, if you need to convert British Pounds (GBP) to Hong Kong Dollars (HKD), the calculation is equal to converting the GBP to USD first, then converting those USD to HKD - but we can do this in a single step.
 
 // let usd_gbp = 0.6438, usd_hkd = 7.7668
     gbp_hkd = usd_hkd * (1 / usd_gbp)
 
 In other words, if you have the following exchange rates relative to US Dollars (the common 'base'): USD/GBP 0.6438 and USD/HKD 7.7668, then you can calculate GBP/HKD 12.0639 by multiplying 7.7668 by the inverse of 0.6438, or 7.7668 * (1 / 0.6438).
 */

-(NSNumber*)priceForCurrency:(TTCurrency)currency inBaseCurrency:(TTCurrency)baseCurrency
{
    NSNumber* targetCurrencyInUSD = [self priceInUSDBaseForCurrency:currency];
    NSNumber* baseCurrencyInUSD = [self priceInUSDBaseForCurrency:baseCurrency];
    double translatedValue = targetCurrencyInUSD.doubleValue * (1 / baseCurrencyInUSD.doubleValue);
    return @(translatedValue);
}

-(NSNumber*)priceInUSDBaseForCurrency:(TTCurrency)currency
{
    NSNumber* p = [self.currencyValues objectForKey:stringFromCurrency(currency)];
    return p;
}

-(void)reloadRates
{
    NSURLRequest* r = [[NSURLRequest alloc]initWithURL:urlForDataWithBaseCurrency(TTCurrencyAUD) cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.f];
    _urlConnection = [[NSURLConnection alloc]initWithRequest:r delegate:self startImmediately:YES];
    _requestData = [NSMutableData data];
}


#pragma mark - private methods

-(id)init
{
    self = [super init];
    if (self)
    {
        // get the stale data until we load new stuff
        [self setCurrencyValues:self.lastLoadedData];
    }
    return self;
}

-(NSDictionary*)lastLoadedData
{
    NSDictionary* d = [[NSUserDefaults standardUserDefaults]objectForKey:OELastLoadedDataKey];
    if ([d isKindOfClass:[NSDictionary class]])
        return d;
    else
        return nil;
}

-(void)setLastLoadedData:(NSDictionary *)data
{
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:OELastLoadedDataKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


-(NSDate *)lastLoadedDate
{
    NSDate* d = [[NSUserDefaults standardUserDefaults]objectForKey:OELastLoadedDateKey];
    if ([d isKindOfClass:[NSDate class]])
        return d;
    else
        return nil;
}

-(void)setLastLoadedDate:(NSDate*)d
{
    [[NSUserDefaults standardUserDefaults]setObject:d forKey:OELastLoadedDateKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

NSURL* urlForDataWithBaseCurrency(TTCurrency baseCurrency)
{
    if (baseCurrency != TTCurrencyUSD)
        [NSException raise:@"Unsupported" format:@"Buy the premium account before base currencies other than USD are supported"];
    NSMutableString* urlStr = [NSMutableString stringWithString:OEApiBaseURL];
    [urlStr appendFormat:@"?app_id=%@", OEApiKey];
    return [NSURL URLWithString:urlStr];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_requestData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString* responseJsonStr = [[NSString alloc]initWithData:_requestData encoding:NSUTF8StringEncoding];
    NSDictionary* dict = [responseJsonStr objectFromJSONString];
    NSNumber* n = [dict objectForKey:@"timestamp"];
    NSDate* d = [NSDate dateWithTimeIntervalSince1970:[n doubleValue]];
    [self setLastLoadedDate:d];
    [self setLastLoadedData:[dict objectForKey:@"rates"]];
    [self setCurrencyValues:[dict objectForKey:@"rates"]];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:OERatesLoadedNotificationString object:self];
}

@end
