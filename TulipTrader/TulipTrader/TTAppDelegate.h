//
//  TTAppDelegate.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 3/26/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTMasterViewController.h"

@interface TTAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

//@property (assign) IBOutlet NSWindow *window;
@property(nonatomic, retain)NSWindow* theWindow;

@property (assign) IBOutlet NSMenu* theMenu;

@property(nonatomic, retain)TTMasterViewController* masterViewController;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
