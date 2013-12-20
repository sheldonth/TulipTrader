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

-(NSArray*)validateInputString:(NSString*)inputStr
{
    NSArray* a = [inputStr componentsSeparatedByString:@"/"];
    if (a.count == 2)
        return a;
    else
    {
        NSLog(@"Bad Input Format");
        return nil;
    }
}

-(void)promptForKeysWithInformativeText:(NSString*)informative andCompletionBlock:(void (^) (void))completionBlock
{
    NSAlert* a = [NSAlert alertWithMessageText:@"No Exchange Keys Found" defaultButton:@"Exit" alternateButton:@"Check Keys" otherButton:nil informativeTextWithFormat:@"%@", informative];
    NSTextField* input = [[NSTextField alloc]initWithFrame:(NSRect){0, 0, 200, 24}];
    [input setStringValue:@"APIKey"];
    [a setAccessoryView:input];
    NSInteger returnInt = [a runModal];
    if (returnInt == NSAlertDefaultReturn)
    {
        [[NSApplication sharedApplication]terminate:self];
    }
    else if (returnInt == NSAlertAlternateReturn)
    {
        NSArray* sepArr = [input.stringValue componentsSeparatedByString:@"/"];
        if (sepArr.count == 2)
        {
            // @TODO horrible validation.
            [self saveApiKey:[sepArr objectAtIndex:0] andSecret:[sepArr objectAtIndex:1]];
            completionBlock();
        }
        else
        {
            [input setStringValue:nil];
        }
    }
    else
    {
        
    }
}


-(id)init

{
    self = [super init];
    if (self)
    {
        if (![self loadKeys])
            [self promptForKeysWithInformativeText:@"Informative Text" andCompletionBlock:^{
                
            }];
    }
    return self;
}


@end
