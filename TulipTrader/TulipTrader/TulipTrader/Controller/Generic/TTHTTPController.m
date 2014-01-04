//
//  TTHTTPController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/21/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTHTTPController.h"
#import "RUConstants.h"
#import "TTAppDelegate.h"

@interface TTHTTPController()

@property(nonatomic, retain) dispatch_queue_t dataProcessQueue;
@property(nonatomic) TTAppDelegate* appDelegatePtr;


@end

@implementation TTHTTPController

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setDataProcessQueue:dispatch_queue_create("mtgox.api.processQueue", NULL)];
        self.appDelegatePtr = (TTAppDelegate*)[[NSApplication sharedApplication]delegate];
    }
    return self;
}

-(NSString *)apiURL
{
    RU_MUST_OVERRIDE
    return nil;
}

-(void)getFullDepthForCurrency:(TTCurrency)currency withCompletion:(void (^)(NSArray *bids, NSArray *asks, NSDictionary *maxMinTicks))completionBlock withFailBlock:(void (^)(NSError* error))failBlock
{
    RU_MUST_OVERRIDE
}

-(void)getDepthForCurrency:(TTCurrency)currency withCompletion:(void (^)(NSArray *bids, NSArray *asks, NSDictionary *maxMinTicks))completionBlock withFailBlock:(void (^)(NSError* error))failBlock
{
    RU_MUST_OVERRIDE
}


@end
