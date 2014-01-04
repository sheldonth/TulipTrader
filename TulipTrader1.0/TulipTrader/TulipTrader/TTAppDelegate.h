//
//  TTAppDelegate.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/21/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTCurrencySelectionWindow.h"
#import "TTEncryptedKeyController.h"

@interface TTAppDelegate : NSObject <NSApplicationDelegate, TTCurrencySelectionWindowDelegate>

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property(nonatomic, retain)TTEncryptedKeyController* encryptedKeyController;

- (IBAction)saveAction:(id)sender;

- (IBAction)showPreferences:(id)sender;

@end
