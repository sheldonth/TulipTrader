//
//  TTMasterViewController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/6/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTMasterViewController.h"
#import "TTStatusBarView.h"
#import "RUConstants.h"
#import "TTFrameConstants.h"

@interface TTMasterViewController ()

@property(nonatomic, retain)TTStatusBarView* statusBarView;

@end

@implementation TTMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setStatusBarView:[TTStatusBarView new]];
        [_statusBarView setFrame:(NSRect){0, kTTWindowHeight - kTTStatusBarHeight, kTTWindowWidth, kTTStatusBarHeight}];
        [self.view addSubview:_statusBarView];
    }
    
    return self;
}

@end
