//
//  TTTradeExecutionBox.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/22/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTDepthOrder.h"
//#import "TTGoxHTTPController.h"

@class TTGoxHTTPController;

typedef enum{
    TTAccountWindowExecutionStateNone = 0,
    TTAccountWindowExecutionStateBuying,
    TTAccountWindowExecutionStateSelling
}TTAccountWindowExecutionState;

typedef enum{
    TTAccountWindowExecutionTypeNone = 0,
    TTAccountWindowExecutionTypeMarket,
    TTAccountWindowExecutionTypeLimit
}TTAccountWindowExecutionType;

@interface TTTradeExecutionBox : NSBox <NSTextFieldDelegate>

@property(nonatomic)TTAccountWindowExecutionState executionState;
@property(nonatomic)TTAccountWindowExecutionType executionType;

@property(nonatomic, weak)NSArray* bidArray;
@property(nonatomic, weak)NSArray* askArray;

@property(nonatomic, weak)TTGoxHTTPController* httpController;

@end
