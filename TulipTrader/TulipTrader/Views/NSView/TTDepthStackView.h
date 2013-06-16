//
//  TTDepthStackView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/13/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTGoxCurrency.h"

@protocol TTDepthStackViewXAxisDelegate <NSObject>

-(void)redrawXAxisWithBidSideTicks:(NSArray*)bidTicks sellSideTicks:(NSArray*)sellTicks;

@end

typedef enum{
    TTDepthViewChartingProcedureSampling = 0,
    TTDepthViewChartingProcedureAllOrders
}TTDepthViewChartingProcedure;

@interface TTDepthStackView : NSView

@property(nonatomic, readwrite)TTGoxCurrency currency;
@property(nonatomic)NSInteger zoomLevel;
@property(nonatomic)BOOL hasSeededDepthData;
@property(nonatomic)BOOL lineDataIsDirty;
@property(nonatomic)TTDepthViewChartingProcedure chartingProcedure;
@property(nonatomic)id <TTDepthStackViewXAxisDelegate> xAxisDelegate;

-(void)reload;

@end
