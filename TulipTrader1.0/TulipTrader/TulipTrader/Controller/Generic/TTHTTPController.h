//
//  TTHTTPController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/21/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTCurrency.h"

@interface TTHTTPController : NSObject

-(void)getDepthForCurrency:(TTCurrency)currency withCompletion:(void (^)(NSArray* bids, NSArray* asks, NSDictionary* maxMinTicks))completionBlock withFailBlock:(void (^)(NSError* e))failBlock;

-(NSString*)apiURL;

@end
