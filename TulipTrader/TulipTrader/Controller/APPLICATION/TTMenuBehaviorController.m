//
//  TTMenuBehaviorController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/8/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTMenuBehaviorController.h"
#import "TTAppDelegate.h"
#import "RUConstants.h"
#import "TTGraphsWindow.h"
#import "TTGraphsWindow.h"

#import <CorePlot/CorePlot.h>

@interface TTMenuBehaviorController()

@property(weak)NSMenu* tulipTraderApplicationMenu;
@property(weak)NSMenu* visualizationsMenu;
@property(weak)NSMenuItem* graphsMenuItem;

@property(nonatomic, retain)TTGraphsWindow* graphsWindow;

@end

@implementation TTMenuBehaviorController

RU_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(TTMenuBehaviorController, sharedInstance);

-(void)launchGraphsWindow:(id)sender
{
    if (!_graphsWindow)
    {
        NSScreen* currentScreen = [NSScreen mainScreen];
        _graphsWindow = [[TTGraphsWindow alloc]initWithContentRect:(NSRect){50, 50, CGRectGetWidth(currentScreen.frame) - 100, CGRectGetHeight(currentScreen.frame) - 100} styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask) backing:NSBackingStoreBuffered defer:NO];
        [_graphsWindow makeKeyAndOrderFront:self];
    }
}

-(void)establishPointers
{
    _tulipTraderApplicationMenu = [[_menu itemWithTitle:@"TulipTrader"] submenu];
    _visualizationsMenu = [[_tulipTraderApplicationMenu itemWithTitle:@"Visualizations"] submenu];
    _graphsMenuItem = [_visualizationsMenu itemWithTitle:@"Graphs"];
}

-(void)bind
{
    if (!_graphsMenuItem)
        {NSException* e = [NSException exceptionWithName:NSInternalInconsistencyException reason:@"No graphs Menu Item" userInfo:nil]; @throw e;}
    [_graphsMenuItem setEnabled:YES];
    [_graphsMenuItem setTarget:self];
    [_graphsMenuItem setAction:@selector(launchGraphsWindow:)];
}

-(id)init
{
    self = [super init];
    if (self)
    {
        TTAppDelegate* appDelegate = (TTAppDelegate*)[[NSApplication sharedApplication]delegate];
        _menu = [appDelegate theMenu];
        [self establishPointers];
        [self bind];
    }
    return self;
}

@end
