//
//  AccountPreferencesViewController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/7/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "AccountPreferencesViewController.h"

@interface AccountPreferencesViewController ()

@end

@implementation AccountPreferencesViewController

- (id)init
{
    return [super initWithNibName:@"AccountPreferencesViewController" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"Accounts";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:@"accountsMan"];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Accounts", @"Toolbar item name for the accounts preference pane");
}

@end
