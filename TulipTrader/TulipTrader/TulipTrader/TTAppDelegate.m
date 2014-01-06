//
//  TTAppDelegate.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/21/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTAppDelegate.h"
#import "TTOrderBook.h"
#import "TTOrderBookWindow.h"
#import "GeneralPreferencesViewController.h"
#import "RulesPreferencesViewController.h"
#import "AccountPreferencesViewController.h"
#import "RUConstants.h"
#import "TTAccountWindow.h"
#import <MASPreferencesWindowController.h>

@interface TTAppDelegate()

@property(nonatomic, retain)TTCurrencySelectionWindow* orderBookWindow;
@property(nonatomic, retain)MASPreferencesWindowController* preferencesWindowController;
@property(nonatomic, retain)TTAccountWindow* accountWindow;


@end

@implementation TTAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

static NSSize defaultWelcomeWindowSize;

#pragma mark - Static Methods

+(void)initialize
{
    defaultWelcomeWindowSize = (NSSize){700, 400};
}

#pragma mark - Menu Events

NSString *const kFocusedAdvancedControlIndex = @"FocusedAdvancedControlIndex";

- (NSInteger)focusedAdvancedControlIndex
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kFocusedAdvancedControlIndex];
}

- (void)setFocusedAdvancedControlIndex:(NSInteger)focusedAdvancedControlIndex
{
    [[NSUserDefaults standardUserDefaults] setInteger:focusedAdvancedControlIndex forKey:kFocusedAdvancedControlIndex];
}

-(void)showPreferences:(id)sender displayingPanelAtIndex:(NSInteger)panelIndex
{
    if (!self.preferencesWindowController)
    {
        NSViewController* generalViewController = [[GeneralPreferencesViewController alloc]init];
        NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
        
        NSViewController* rulesViewController = [[RulesPreferencesViewController alloc]init];
        NSViewController* accountsViewController = [[AccountPreferencesViewController alloc]init];
        _preferencesWindowController = [[MASPreferencesWindowController alloc]initWithViewControllers:@[generalViewController,rulesViewController, accountsViewController] title:title];
    }
    [self.preferencesWindowController showWindow:nil];
    [self.preferencesWindowController selectControllerAtIndex:panelIndex];
}

-(void)showPreferences:(id)sender
{
    [self showPreferences:sender displayingPanelAtIndex:0];
}

-(void)showAccount
{
//    NSRect browserRect = [self.browser.windowController.window frame];
//    CGFloat browserHorizontalSize = browserRect.origin.x + browserRect.size.width;
//    CGFloat screenWidth = [[NSScreen mainScreen]frame].size.width;
//    [self setAccountWindow:[[TTAccountWindow alloc]initWithContentRect:(NSRect){browserHorizontalSize, 0, screenWidth - browserHorizontalSize, browserRect.size.height} styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask) backing:NSBackingStoreBuffered defer:YES]];
//    [self.accountWindow setTitle:@"Account"];
//    [self.accountWindow setOrderBook:self.browser.orderBook];
//    [self.accountWindow setAnimationBehavior:NSWindowAnimationBehaviorDocumentWindow];
//    [self.accountWindow makeKeyAndOrderFront:self];
}

-(void)showBrowser
{
    NSLog(@"!");
}

#pragma mark - TTNewOrderBookWindowDelegate

-(void)didFinishSelectionForWindow:(TTCurrencySelectionWindow *)window currencies:(NSArray *)currencies
{
    [window close];
}

#pragma mark - Private Methods

-(void)presentCurrencySelectionScreen
{
    if (!self.orderBookWindow)
    {
        NSRect r = [[NSScreen mainScreen]visibleFrame];
        [self setOrderBookWindow:[[TTCurrencySelectionWindow alloc]initWithContentRect:(NSRect){CGRectGetMidX(r) - (defaultWelcomeWindowSize.width / 2), CGRectGetHeight(r) - (defaultWelcomeWindowSize.height + 150), defaultWelcomeWindowSize} styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask) backing:NSBackingStoreBuffered defer:YES]];
    }
    [self.orderBookWindow setOrderBookWindowDelegate:self];
    [self.orderBookWindow makeKeyAndOrderFront:self];
}

#pragma mark - UIApplicationDelegate Methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setEncryptedKeyController:[[TTEncryptedKeyController alloc]init]];
    [_encryptedKeyController loadKeysWithCompletionBlock:^(NSNumber *result) {
        if (result.boolValue)
        {
            [self showBrowser];
            [self showAccount];
        }
        else
        {
            [self showBrowser];
        }
    }];
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "net.tuliptrader.TulipTrader" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"net.tuliptrader.TulipTrader"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TulipTrader" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"TulipTrader.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
