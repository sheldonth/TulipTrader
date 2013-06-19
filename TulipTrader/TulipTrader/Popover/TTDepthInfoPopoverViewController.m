//
//  TTDepthInfoPopoverViewController.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/18/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTDepthInfoPopoverViewController.h"
#import "RUConstants.h"
#import "TTDepthInfoPopoverView.h"

@interface TTDepthInfoPopoverViewController ()

@property(nonatomic)NSSize canvasSize;

@end

@implementation TTDepthInfoPopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andViewSize:(NSSize)size
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self setCanvasSize:size];
    }
    
    return self;
}

-(void)loadView
{
    // No need to keep the pointer to v, it's always self.view
    TTDepthInfoPopoverView* v = [[TTDepthInfoPopoverView alloc]initWithFrame:(NSRect){0, 0, self.canvasSize}];
    [v setBackgroundColor:[NSColor whiteColor]];
    [self setView:v];
}

@end
