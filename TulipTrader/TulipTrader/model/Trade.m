//
//  Trade.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/13/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
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

int64_t latestTradeID()
{

}

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

+(void)computeFunctionNamed:(NSString*)functionName onTradePropertyWithName:(NSString*)propertyName completion:(void (^)(NSNumber* computedResult))callbackBlock
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


+(Trade*)newTradeInContext:(NSManagedObjectContext*)context fromDictionary:(NSDictionary*)d
{
    return [Trade newTradeInContext:context fromDictionary:d precision:TradePrecisionDouble];
}

+(Trade*)newTradeInContext:(NSManagedObjectContext*)context fromDictionary:(NSDictionary*)d precision:(TradePrecision)precision
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
    return t;
}

@end
