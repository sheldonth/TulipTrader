//
//  TTDatabaseLoader.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/12/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTDatabaseLoader.h"
#import "RUConstants.h"
#import "FMDatabase.h"

@implementation TTDatabaseLoader

+(void)loadDatabaseAtUrl:(NSURL*)url
{
    FMDatabase* db = [FMDatabase databaseWithPath:url.pathExtension];
    if (![db open])
    {
        RUDLog(<#fmt, ...#>)
    }
}

+(void)showFilePicker
{
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
            NSAlert* alert = [NSAlert alertWithMessageText:@"Bad File Chose" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You must chose a file with type .sqlite3"];
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
