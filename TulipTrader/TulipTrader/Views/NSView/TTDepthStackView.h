//
//  TTDepthStackView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/13/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTGoxCurrency.h"

typedef enum{
    TTDepthViewLimitOrderMarketSideNone = 0,
    TTDepthViewLimitOrderMarketSideBid,
    TTDepthViewLimitOrderMarketSideAsk,
}TTDepthViewLimitOrderMarketSide;

typedef enum{
    TTDepthViewChartingProcedureSampling = 0,
    TTDepthViewChartingProcedureAllOrders
}TTDepthViewChartingProcedure;


@protocol TTDepthStackViewModalDelegate <NSObject>
// Depth object can be a TTDepthPositionValue or TTDepthOrder
-(void)presentDepthPositionModalForDepthObject:(id)depthObject atLocalPoint:(NSPoint)point;
-(void)dismissAllDepthPositionModals;

@end

@protocol TTDepthStackViewLabelingDelegate <NSObject>

-(void)updatePriceString:(NSString*)priceString;;
-(void)shouldEndShowingPrice;
-(void)shouldEndShowingInfoPane;

-(void)redrawXAxisWithBidSideTicks:(NSArray*)bidTicks sellSideTicks:(NSArray*)sellTicks;

@end

@interface TTDepthStackView : NSView

@property(nonatomic, readwrite)TTGoxCurrency currency;
@property(nonatomic)NSInteger zoomLevel;
@property(nonatomic)BOOL hasSeededDepthData;
@property(nonatomic)BOOL lineDataIsDirty;
@property(nonatomic)TTDepthViewChartingProcedure chartingProcedure;
@property(nonatomic)BOOL isReloading;

@property(nonatomic)id <TTDepthStackViewLabelingDelegate> labelingDelegate;

-(void)reload;

@end
