//
//  TTOERatesController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/29/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTOERatesController.h"
#import "TTGoxCurrency.h"
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

@implementation TTOERatesController

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

NSURL* urlForDataWithBaseCurrency(TTGoxCurrency baseCurrency)
{
    if (baseCurrency != TTGoxCurrencyUSD)
        [NSException raise:@"Unsupported" format:@"Buy the premium account before base currencies other than USD are supported"];
    NSMutableString* urlStr = [NSMutableString stringWithString:OEApiBaseURL];
    [urlStr appendFormat:@"?app_id=%@", OEApiKey];
    return [NSURL URLWithString:urlStr];
}

-(void)reloadRates
{
    NSURLRequest* r = [[NSURLRequest alloc]initWithURL:urlForDataWithBaseCurrency(TTGoxCurrencyUSD) cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.f];
    _urlConnection = [[NSURLConnection alloc]initWithRequest:r delegate:self startImmediately:YES];
    _requestData = [NSMutableData data];
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
}


@end
