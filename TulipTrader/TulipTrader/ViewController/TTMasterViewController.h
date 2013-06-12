//
//  TTMasterViewController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/6/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTArbGridView.h"
#import "TTDepthGridView.h"

typedef enum{
    TTMasterViewControllerBodyContentStateArbTables = 0,
    TTMasterViewControllerBodyContentStateDepthTables,
}TTMasterViewControllerBodyContentState;

@interface TTMasterViewController : NSView

-(void)setViewFrameAndInformSubviews:(NSRect)newFrame;

@property(nonatomic, retain)TTArbGridView* arbGridView;
@property(nonatomic, retain)TTDepthGridView* depthGridView;
@property(nonatomic)TTMasterViewControllerBodyContentState bodyState;
-(void)setToBodyState:(TTMasterViewControllerBodyContentState)bodyState;// WithCompletion:(void (^)())completion;

@end
