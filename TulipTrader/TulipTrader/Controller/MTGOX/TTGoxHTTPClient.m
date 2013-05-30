//
//  TTGoxHTTPClient.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/28/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//
/*
 NSData* firstPart = [method dataUsingEncoding:NSUTF8StringEncoding];
 
 //    char partTwoBytes[] = "";
 
 NSData* secondPart = [NSData dataWithBytes:partTwoBytes length:sizeof(partTwoBytes)];
 
 NSData* partThree = [req HTTPBody];
 
 NSMutableData* combined = [NSMutableData dataWithData:firstPart];
 
 [combined appendData:secondPart];
 
 [combined appendData:partThree];
 //    const char *bytePtr = (const char *)[combined bytes];
 
 NSString* dataString = [[NSString alloc]initWithData:combined encoding:NSUTF8StringEncoding];
 
 */

#import <CommonCrypto/CommonHMAC.h>
#import "TTGoxHTTPClient.h"
#import "NSData+Base64.h"
#import "RUConstants.h"
#import "NSData+SRB64Additions.h"

@implementation TTGoxHTTPClient

#define kTTUserAgent @"Tulip Trader/1.0 (Mac OS X)"

static NSString* APIKEY;
static NSString* APISECRET;

NSString* const kTTMTGoxAPIKeyKey = @"MTGOXUserAPIKey";
NSString* const kTTMTGoxAPISecretKey = @"MTGOXUserAPISecret";

+(void)initialize
{
    NSDictionary* d = [[NSDictionary alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"UserData" ofType:@"plist"]];
    if (!d)
    {
        NSAlert* a = [NSAlert alertWithMessageText:@"No UserData plist was found." defaultButton:@"Ok" alternateButton:@"Open plist File (not implemented yet)" otherButton:nil informativeTextWithFormat:@"You cannot authenticate with exchanges without first entering your access credentials in the UserData.plist file."];
        [a runModal];
    }
    else
    {
        APIKEY = [d objectForKey:kTTMTGoxAPIKeyKey];
        APISECRET = [d objectForKey:kTTMTGoxAPISecretKey];
        if (!APIKEY)
            RUDLog(@"No API KEY!");
        if (!APISECRET)
            RUDLog(@"NO API SECRET!");
    }
}

NSString* currentTonce()
{
    double d = ([[NSDate date]timeIntervalSince1970] * 1000.0);
    
    NSString* nonceString = RUStringWithFormat(@"%.0f", d);
    
    return nonceString;
}

NSString* HMAC_Out(NSString *msg, NSString *sec)
{
    unsigned long msg_len = [msg length];
    const char *msg_c = [msg UTF8String];
    
    NSData* dec = [NSData dataFromBase64String:sec];
    unsigned long dec_len = [dec length];
    const char *dec_c = (char*)[dec bytes];
    
    unsigned char cHMAC[CC_SHA512_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA512, dec_c, dec_len, msg_c, msg_len, cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString* ret = [HMAC base64EncodedString];
    return [ret stringByReplacingOccurrencesOfString: @"\r\n" withString:@""];
}

-(NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
{
    NSMutableDictionary* mutableParams;

    if (parameters)
        mutableParams = [parameters mutableCopy];
    else
        mutableParams = [NSMutableDictionary dictionary];
    
    [mutableParams setObject:currentTonce() forKey:@"nonce"];
    
    NSMutableURLRequest* req = [[super requestWithMethod:method path:path parameters:mutableParams]mutableCopy];
    
    [req setValue:kTTUserAgent forHTTPHeaderField:@"User-Agent"];
    
    [req setValue:APIKEY forHTTPHeaderField:@"Rest-Key"];
    
    NSString* reqBodyString = [[NSString alloc]initWithData:[req HTTPBody] encoding:NSUTF8StringEncoding];
    
    NSString* hmacMessage = [NSString stringWithFormat:@"%@\0%@", path, reqBodyString];
    
    NSMutableString* hmacVal = [NSMutableString stringWithString:HMAC_Out(hmacMessage, APISECRET)];
    
    [req setValue:hmacVal forHTTPHeaderField:@"Rest-Sign"];
    
    return req;
}



@end
