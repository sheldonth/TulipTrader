//
//  RulesPreferencesViewController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/1/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RulesPreferencesViewController : NSViewController

@property(nonatomic, retain)IBOutlet NSPopUpButton* positiveDeltaPopupBtn;
@property(nonatomic, retain)IBOutlet NSPopUpButton* negativeDeltaPopupBtn;


-(IBAction)positiveDeltaPopupValueChanged:(id)sender;
-(IBAction)negativeDeltaPopupValueChanged:(id)sender;

@end

static NSString* incrementInconsistencySidesWithClient;
static NSString* decrementInconsistencySidesWithClient;
