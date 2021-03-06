//
//  TTGoxHTTPClient.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/28/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <CommonCrypto/CommonHMAC.h>
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>
#import "TTGoxHTTPClient.h"
#import "NSData+Base64.h"
#import "RUConstants.h"
#import "NSData+SRB64Additions.h"
#import "TTConstants.h"
#import "TTEncryptedKeyController.h"
#import "TTAppDelegate.h"


@interface TTGoxHTTPClient()

@property(nonatomic)TTAppDelegate* appDelegate;

@end

@implementation TTGoxHTTPClient

#define kTTUserAgent @"Tulip Trader/1.0 (Mac OS X)"

#define kTTUserDefaultsNonceKey @"TTUserDefaultNonceKey"


-(id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self)
    {
        [self setAppDelegate:(TTAppDelegate*)[[NSApplication sharedApplication]delegate]];
    }
    return self;
}

NSString* currentDateTonce()
{
    double d = ([[NSDate date]timeIntervalSince1970] * 1000.0);
    
    NSString* nonceString = RUStringWithFormat(@"%.0f", d);
    
    return nonceString;
}

NSString* currentIncrementalTonce()
{
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* a = [standardUserDefaults objectForKey:kTTUserDefaultsNonceKey];
    if (!a)
        a = @(1);
    [standardUserDefaults setObject:@(a.intValue + 1) forKey:kTTUserDefaultsNonceKey];
    [standardUserDefaults synchronize];
    return a.stringValue;
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
    
//    NSString* tonce = currentDateTonce();

    NSString* tonce = currentIncrementalTonce();
    
    [mutableParams setObject:tonce forKey:@"nonce"];
    
    NSMutableURLRequest* req = [[super requestWithMethod:method path:path parameters:mutableParams]mutableCopy];
    
    [req setValue:kTTUserAgent forHTTPHeaderField:@"User-Agent"];
    
    [req setValue:_appDelegate.encryptedKeyController.apiKey forHTTPHeaderField:@"Rest-Key"];
    
    NSString* reqBodyString = [[NSString alloc]initWithData:[req HTTPBody] encoding:NSUTF8StringEncoding];
    
    NSString* hmacMessage = [NSString stringWithFormat:@"%@\0%@", path, reqBodyString];
    
    NSMutableString* hmacVal = [NSMutableString stringWithString:HMAC_Out(hmacMessage, _appDelegate.encryptedKeyController.apiSecret)];
    
    [req setValue:hmacVal forHTTPHeaderField:@"Rest-Sign"];
    
    return req;
}



@end
