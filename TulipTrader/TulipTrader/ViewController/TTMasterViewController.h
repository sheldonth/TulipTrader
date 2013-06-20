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
#import "TTAPIControlBoxView.h"
#import "TTAccountBox.h"
#import "TTGoxSocketController.h"
#import "TTGoxPrivateMessageController.h"

typedef enum{
    TTMasterViewControllerBodyContentStateArbTables = 0,
    TTMasterViewControllerBodyContentStateDepthTables,
}TTMasterViewControllerBodyContentState;

@interface TTMasterViewController : NSView <TTGoxSocketControllerMessageDelegate, TTGoxPrivateMessageControllerDepthDelegate, TTGoxPrivateMessageControllerLagDelegate, TTGoxPrivateMessageControllerTradesDelegate, TTGoxPrivateMessageControllerTickerDelegate>

@property(nonatomic, retain) TTArbGridView* arbGridView;
@property(nonatomic, retain) TTDepthGridView* depthGridView;
@property(nonatomic) TTMasterViewControllerBodyContentState bodyState;
@property(nonatomic, retain)TTAPIControlBoxView* controlBoxView;
@property(nonatomic, retain)TTAccountBox* accountBox;
@property(nonatomic, retain)TTGoxSocketController* socketController;

-(void)setToBodyState:(TTMasterViewControllerBodyContentState)bodyState;

@end
