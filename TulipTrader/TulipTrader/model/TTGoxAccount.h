//
//  TTGoxAccount.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/31/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tick.h"

@interface TTGoxAccount : NSObject

@property(nonatomic, retain)NSString* username;
@property(nonatomic, retain)NSString* language;
@property(nonatomic, retain)NSString* ID;
@property(nonatomic, retain)NSDate* createdDate;
@property(nonatomic, retain)NSDate* loginDate;
@property(nonatomic, retain)InMemoryTick* monthlyVolume;
@property(nonatomic, retain)NSArray* permissionsArray;
@property(nonatomic, retain)NSNumber* tradeFee;
@property(nonatomic, retain)NSArray* currencyWallets;
@property(nonatomic, retain)NSNumber* indexNumber;

TTGoxAccount* accountFromDictionary(NSDictionary* accountDictionary);

@end