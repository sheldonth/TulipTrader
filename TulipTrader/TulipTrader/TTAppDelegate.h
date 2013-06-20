//
//  TTAppDelegate.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 3/26/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTMarketSelectionWelcomeWindow.h"

@interface TTAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, MarketSelectionWindowDelegate>

@property(nonatomic, retain)NSMutableArray* windows;

@property (assign) IBOutlet NSMenu* theMenu;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
