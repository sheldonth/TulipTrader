//
//  TTDatabaseLoader.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/12/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTDatabaseLoader.h"
#import "RUConstants.h"
#import "FMDatabase.h"
#import "TTGoxCurrency.h"
#import "Trade.h"
#import "TTAppDelegate.h"
#import "TTAPIControlBoxView.h"

#define kECTTDatabaseLoaderSaveInterval 300

@implementation TTDatabaseLoader

+(void)loadDatabaseAtUrl:(NSURL*)url
{
    [TTAPIControlBoxView publishCommand:@"Database Loading Started"];
    FMDatabase* db = [FMDatabase databaseWithPath:url.absoluteString];
    if (![db open])
    {
        RUDLog(@"Database couldn't be opened!");
    }
    else
    {
        RUDLog(@"Starting Import");
        dispatch_queue_t dbProcessQueue = dispatch_queue_create("db_process_queue", NULL);
        dispatch_async(dbProcessQueue, ^{
            TTAppDelegate* appDelegate = (TTAppDelegate*)[[NSApplication sharedApplication]delegate];
            NSManagedObjectContext* dbProcessQueueMOC = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [dbProcessQueueMOC setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
            FMResultSet* set = [db executeQuery:@"SELECT * FROM trades"];
            while ([set next]) {
                long long tradeId = [set longLongIntForColumn:@"tid"];
                NSString* currencyString = [set stringForColumn:@"currency"];
                double amount = [set doubleForColumn:@"amount"];
                double price = [set doubleForColumn:@"price"];
                long long dateInteger = [set longLongIntForColumn:@"date"];
                BOOL realBoolean = [set boolForColumn:@"real"];
                
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:@(tradeId) forKey:@"tid"];
                [dict setObject:numberFromCurrencyString(currencyString) forKey:@"currency"];
                [dict setObject:@(amount) forKey:@"amount"];
                [dict setObject:@(price) forKey:@"price"];
                [dict setObject:@(dateInteger) forKey:@"date"];
                realBoolean ? [dict setObject:@"Y" forKey:@"primary"] : [dict setObject:@"N" forKey:@"primary"];
                
                [Trade newDatabaseTradeInContext:dbProcessQueueMOC fromDictionary:dict];
                }
            NSError* e = nil;
            [dbProcessQueueMOC save:&e];
            if (e)
                RUDLog(@"Error importing database!");
            else
            {
                [TTAPIControlBoxView publishCommand:@"Database loaded."];
                [db close];
            }
        });
    }
}

+(void)showFilePicker
{
    if (![NSThread isMainThread])
        dispatch_async(dispatch_get_main_queue(), ^{
            [TTDatabaseLoader showFilePicker];
            return;
        });
    
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setTitle:@"Choose SQLite Database"];
    
    NSInteger result = [panel runModal];
    if (result == NSFileHandlingPanelOKButton)
    {
        NSURL* url = [panel URL];
        if (![[url pathExtension]isEqualToString:@"sqlite3"])
        {
            NSAlert* alert = [NSAlert alertWithMessageText:@"Bad File Choice" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You must chose a file with type .sqlite3"];
            NSInteger result = [alert runModal];
            return;
        }
        else
        {
            [self loadDatabaseAtUrl:url];
        }
    }
}

@end
