//
//  TTEncryptedKeyController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 12/20/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//


#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>
#import "TTEncryptedKeyController.h"
#import "TTConstants.h"

@implementation TTEncryptedKeyController

#define kTTUserDefaultsMTGOXAPIKey @"MTGOX_APIKEY"
#define kTTUserDefaultsMTGOXAPISECRET @"MTGOX_APISECRET"

-(void)saveApiKey:(NSString*)key andSecret:(NSString*)secret
{
    [[NSUserDefaults standardUserDefaults]setSecretObject:key forKey:kTTUserDefaultsMTGOXAPIKey];
    [[NSUserDefaults standardUserDefaults]setSecretObject:secret forKey:kTTUserDefaultsMTGOXAPISECRET];
}

-(BOOL)loadKeys
{
    [[NSUserDefaults standardUserDefaults]setSecret:kTTSecureUserDefaultsSecretKey];
    NSString* apiK = [[NSUserDefaults standardUserDefaults]secretStringForKey:kTTUserDefaultsMTGOXAPIKey];
    NSString* apiS = [[NSUserDefaults standardUserDefaults]secretStringForKey:kTTUserDefaultsMTGOXAPISECRET];
    _apiKey = [apiK copy];
    _apiSecret = [apiS copy];
    if (apiK && apiS)
        return YES;
    else
    {
        apiK = nil;
        apiS = nil;
        return NO;
    }
    
}

-(void)loadKeysWithCompletionBlock:(void (^) (NSNumber* result))completionBlock
{
    BOOL result = [self loadKeys];
    completionBlock(@(result));
}



@end
