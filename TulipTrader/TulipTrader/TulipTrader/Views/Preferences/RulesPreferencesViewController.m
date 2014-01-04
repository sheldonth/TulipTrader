//
//  RulesPreferencesViewController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/1/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "RulesPreferencesViewController.h"
#import "RUConstants.h"

@interface RulesPreferencesViewController ()

@end

@implementation RulesPreferencesViewController

+(void)initialize
{
    if (self == [RulesPreferencesViewController class])
    {
        incrementInconsistencySidesWithClient = @"kTTIncrementingDepthOrderRespectClientVolume";
        decrementInconsistencySidesWithClient = @"kTTDecrementingDepthOrderRespectClientVolume";
    }
}

-(void)positiveDeltaPopupValueChanged:(NSPopUpButton*)sender
{
    [[NSUserDefaults standardUserDefaults]setObject:@(sender.indexOfSelectedItem) forKey:incrementInconsistencySidesWithClient];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void)negativeDeltaPopupValueChanged:(NSPopUpButton*)sender
{
    [[NSUserDefaults standardUserDefaults]setObject:@(sender.indexOfSelectedItem) forKey:decrementInconsistencySidesWithClient];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (id)init
{
    return [super initWithNibName:@"RulesPreferencesViewController" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController

-(void)awakeFromNib
{
    [self.positiveDeltaPopupBtn.itemArray enumerateObjectsUsingBlock:^(NSMenuItem* obj, NSUInteger idx, BOOL *stop) {
        [obj setState:0];
    }];
    [self.negativeDeltaPopupBtn.itemArray enumerateObjectsUsingBlock:^(NSMenuItem* obj, NSUInteger idx, BOOL *stop) {
        [obj setState:0];
    }];

    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* inc = [userDefaults objectForKey:incrementInconsistencySidesWithClient];
    inc.boolValue ? [self.positiveDeltaPopupBtn selectItemAtIndex:0] : [self.positiveDeltaPopupBtn selectItemAtIndex:1];
    [self.positiveDeltaPopupBtn synchronizeTitleAndSelectedItem];
    NSNumber* dec = [userDefaults objectForKey:decrementInconsistencySidesWithClient];
    dec.boolValue ? [self.negativeDeltaPopupBtn selectItemAtIndex:0] : [self.negativeDeltaPopupBtn selectItemAtIndex:1];
    [self.negativeDeltaPopupBtn synchronizeTitleAndSelectedItem];
}

- (NSString *)identifier
{
    return @"Data Rules";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameAdvanced];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Data Rules", @"Toolbar item name for the General preference pane");
}

@end
