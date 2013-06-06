//
//  Trade.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/13/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "Trade.h"
#import "RUClassOrNilUtil.h"
#import "RUConstants.h"
#import "TTGoxCurrency.h"
#import "TTAppDelegate.h"

typedef enum{
    TradePrecisionInt = 0,
    TradePrecisionDouble
}TradePrecision;

@implementation Trade


@dynamic tradeId;
@dynamic currency;
@dynamic amount;
@dynamic price;
@dynamic date;
@dynamic real_boolean;
@dynamic trade_type;
@dynamic properties;

#pragma c methods

#pragma mark - class methods

-(NSString *)description
{
    return RUStringWithFormat(@"Trade %@ in %@ for %@ at %@ and is real %@", self.tradeId.stringValue, stringFromCurrency(currencyFromNumber(self.currency)), self.amount.stringValue, self.price.stringValue, self.real_boolean.stringValue);
}

#pragma mark - static Methods

/*
 @purpose: seek only the function on the property in a given mox
 @functionName @"max:"
 @propertyName @"price"
 */

+(void)findTradesWithPredicate:(NSPredicate*)p completion:(void (^)(NSArray* results))callbackBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        TTAppDelegate* appDelegate = (TTAppDelegate*)[[NSApplication sharedApplication]delegate];
        NSManagedObjectContext* c = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [c setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
        
        NSFetchRequest* f = [[NSFetchRequest alloc]initWithEntityName:@"Trade"];
        [f setPredicate:p];
        [f setIncludesPropertyValues:NO];
        
        NSArray* results = [c executeFetchRequest:f error:nil];
        callbackBlock(results);
    });
}

+(void)computeFunctionNamed:(NSString*)functionName onTradePropertyWithName:(NSString*)propertyName completion:(void (^)(NSNumber* computedResult))callbackBlock
{
    return [Trade computeFunctionNamed:functionName onTradePropertyWithName:propertyName optionalPredicate:nil completion:callbackBlock];
}

+(void)computeFunctionNamed:(NSString*)functionName onTradePropertyWithName:(NSString*)propertyName optionalPredicate:(NSPredicate*)predicate completion:(void (^)(NSNumber* computedResult))callbackBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        TTAppDelegate* appDelegate = (TTAppDelegate*)[[NSApplication sharedApplication]delegate];
        NSExpression* keyExpression = [NSExpression expressionForKeyPath:propertyName];
        NSExpression* maxExpression = [NSExpression expressionForFunction:functionName arguments:@[keyExpression]];
        
        NSExpressionDescription* description = [NSExpressionDescription new];
        [description setName:@"evaluationResult"];
        [description setExpression:maxExpression];
        [description setExpressionResultType:NSDoubleAttributeType];

        NSManagedObjectContext* context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [context setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
        
        NSFetchRequest* request = [[NSFetchRequest alloc]initWithEntityName:@"Trade"];
        if (predicate)
            [request setPredicate:predicate];
        [request setPropertiesToFetch:@[description]];
        [request setResultType:NSDictionaryResultType];
    
        NSError* e = nil;
        NSArray* dataSet = [context executeFetchRequest:request error:&e];
        
        if ([[[dataSet objectAtIndex:0]allObjects] count])
        {
            NSNumber* result = [[dataSet objectAtIndex:0] objectForKey:@"evaluationResult"];
            dispatch_async(dispatch_get_main_queue(), ^{
                callbackBlock(result);
            });
        }
    });
}

+(Trade*)newNetworkTradeInContext:(NSManagedObjectContext*)context fromDictionary:(NSDictionary*)d
{
    Trade* t = [NSEntityDescription insertNewObjectForEntityForName:@"Trade" inManagedObjectContext:context];
    NSNumberFormatter* numberFormatter = [NSNumberFormatter new];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber* result = [numberFormatter numberFromString:[d objectForKey:@"tid"]];
    [t setTradeId:result];
    [t setCurrency:numberFromCurrencyString([d objectForKey:@"price_currency"])];
    if ([[d objectForKey:@"amount"]isKindOfClass:[NSString class]])
        [t setAmount:[numberFormatter numberFromString:[d objectForKey:@"amount"]]];
    else
        [t setAmount:[d objectForKey:@"amount"]];
    if ([[d objectForKey:@"price"]isKindOfClass:[NSString class]])
        [t setPrice:[numberFormatter numberFromString:[d objectForKey:@"price"]]];
    else
        [t setPrice:[d objectForKey:@"price"]];
    [t setDate:[NSDate dateWithTimeIntervalSince1970:[[d objectForKey:@"date"]doubleValue]]];
    if ([[d objectForKey:@"primary"] isEqualToString:@"Y"])
        [t setReal_boolean:@(1)];
    else if ([[d objectForKey:@"primary"] isEqualToString:@"N"])
        [t setReal_boolean:@(0)];
    [t setTrade_type:kRUStringOrNil([d objectForKey:@"trade_type"])];
    [t setProperties:kRUStringOrNil([d objectForKey:@"properties"])];
    
    if (!t.price || !t.amount || !t.tradeId)
        RUDLog(@"ERROR SAVING");
    
    return t;
}

+(Trade*)newDatabaseTradeInContext:(NSManagedObjectContext*)context fromDictionary:(NSDictionary*)d
{
    Trade* t = [NSEntityDescription insertNewObjectForEntityForName:@"Trade" inManagedObjectContext:context];
    [t setTradeId:kRUNumberOrNil([d objectForKey:@"tid"])];
    [t setCurrency:kRUNumberOrNil([d objectForKey:@"currency"])];
    [t setAmount:kRUNumberOrNil([d objectForKey:@"amount"])];
    [t setPrice:kRUNumberOrNil([d objectForKey:@"price"])];
    [t setDate:[NSDate dateWithTimeIntervalSince1970:[[d objectForKey:@"date"]doubleValue]]];
    if ([[d objectForKey:@"primary"] isEqualToString:@"Y"])
        [t setReal_boolean:@(1)];
    else if ([[d objectForKey:@"primary"] isEqualToString:@"N"])
        [t setReal_boolean:@(0)];
    [t setTrade_type:kRUStringOrNil([d objectForKey:@"trade_type"])];
    [t setProperties:kRUStringOrNil([d objectForKey:@"properties"])];
    if (!t.price || !t.amount || !t.tradeId)
        RUDLog(@"ERROR SAVING");
    return t;
}

@end
