//
//  TTMenuBehaviorController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/8/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTMenuBehaviorController.h"
#import "TTAppDelegate.h"
#import "RUConstants.h"
#import "TTGraphsWindow.h"
#import "TTGraphsWindow.h"
#import "TTDatabaseLoader.h"
#import "TTMasterViewController.h"
#import <CorePlot/CorePlot.h>

#define TTGraphWindowInset 25.f

@interface TTMenuBehaviorController()

@property(weak)NSMenu* tulipTraderApplicationMenu;
@property(weak)NSMenu* fileMenu;
@property(weak)NSMenuItem* loadDBMenuItem;
@property(weak)NSMenu* visualizationsMenu;
@property(weak)NSMenuItem* graphsMenuItem;
@property(weak)NSMenu* settingsMenu;
@property(weak)NSMenuItem* arbTablesMenuItem;
@property(weak)NSMenuItem* depthTablesMenuItem;
@property(nonatomic, retain)TTGraphsWindow* graphsWindow;

@end

@implementation TTMenuBehaviorController

RU_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(TTMenuBehaviorController, sharedInstance);

-(void)jumpToDepthTable:(id)sender
{
    [[_appDelegate masterViewController]setToBodyState:(TTMasterViewControllerBodyContentStateDepthTables)];
}

-(void)jumpToArbTable:(id)sender
{
    [[_appDelegate masterViewController]setToBodyState:(TTMasterViewControllerBodyContentStateArbTables)];
}

-(void)loadDB:(id)sender
{
    [TTDatabaseLoader showFilePicker];
}

-(void)launchGraphsWindow:(id)sender
{
    if (!_graphsWindow)
    {
        NSScreen* currentScreen = [NSScreen mainScreen];
        _graphsWindow = [[TTGraphsWindow alloc]initWithContentRect:(NSRect){TTGraphWindowInset, TTGraphWindowInset, CGRectGetWidth(currentScreen.frame) - (2 * TTGraphWindowInset), CGRectGetHeight(currentScreen.frame) - (2 * TTGraphWindowInset)} styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask) backing:NSBackingStoreBuffered defer:NO];
        [_graphsWindow makeKeyAndOrderFront:self];
    }
}

-(void)establishPointers
{
    _tulipTraderApplicationMenu = [[_menu itemWithTitle:@"TulipTrader"] submenu];
    _fileMenu = [[_menu itemWithTitle:@"File"] submenu];
    _loadDBMenuItem = [_fileMenu itemWithTitle:@"Load DB"];
    _visualizationsMenu = [[_tulipTraderApplicationMenu itemWithTitle:@"Visualizations"] submenu];
    _graphsMenuItem = [_visualizationsMenu itemWithTitle:@"Graphs"];
    _settingsMenu = [[_menu itemWithTitle:@"Settings"]submenu];
    _arbTablesMenuItem = [_settingsMenu itemWithTitle:@"Show Arb Tables"];
    _depthTablesMenuItem = [_settingsMenu itemWithTitle:@"Show Depth Columns"];
}

-(void)bind
{
    if (!_graphsMenuItem)
        {NSException* e = [NSException exceptionWithName:NSInternalInconsistencyException reason:@"No graphs Menu Item" userInfo:nil]; @throw e;}
    [_graphsMenuItem setEnabled:YES];
    [_graphsMenuItem setTarget:self];
    [_graphsMenuItem setAction:@selector(launchGraphsWindow:)];
    
    [_loadDBMenuItem setEnabled:YES];
    [_loadDBMenuItem setTarget:self];
    [_loadDBMenuItem setAction:@selector(loadDB:)];
    
    [_arbTablesMenuItem setEnabled:YES];
    [_arbTablesMenuItem setTarget:self];
    [_arbTablesMenuItem setAction:@selector(jumpToArbTable:)];
    
    [_depthTablesMenuItem setEnabled:YES];
    [_depthTablesMenuItem setTarget:self];
    [_depthTablesMenuItem setAction:@selector(jumpToDepthTable:)];
}

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setAppDelegate:(TTAppDelegate*)[[NSApplication sharedApplication]delegate]];
        _menu = [self.appDelegate theMenu];
        [self establishPointers];
        [self bind];
    }
    return self;
}

@end
