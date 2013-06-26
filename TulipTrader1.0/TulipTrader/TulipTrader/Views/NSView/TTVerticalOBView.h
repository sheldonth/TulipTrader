//
//  TTVerticalOBView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/13/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTCurrency.h"

typedef enum{
    TTDepthViewChartingProcedureSampling = 0,
    TTDepthViewChartingProcedureAllOrders
}TTVerticalOBViewChartingProcedure;

@protocol TTVerticalOBViewModalDelegate <NSObject>
// Depth object can be a TTDepthPositionValue or TTDepthOrder
-(void)presentDepthPositionModalForDepthObject:(id)depthObject atLocalPoint:(NSPoint)point;
-(void)dismissAllDepthPositionModals;

@end

@protocol TTVerticalOBViewLabelingDelegate <NSObject>

-(void)updatePriceString:(NSString*)priceString;;
-(void)shouldEndShowingPrice;
-(void)shouldEndShowingInfoPane;

-(void)redrawXAxisWithBidSideTicks:(NSArray*)bidTicks sellSideTicks:(NSArray*)sellTicks;

@end

@interface TTVerticalOBView : NSView

// The entire corresponding side of the order book as the TTOrderBook Object believes it to be
// Meant to be set by external users
@property(nonatomic, retain) NSArray* allBids;
@property(nonatomic, retain) NSArray* allAsks;

// The part of the allBids/allAsks array within bidInclusionDifferential/askInclusionDifferential % from the spread.
// Determined each time data is processed
@property(nonatomic, retain) NSArray* bids;
@property(nonatomic, retain) NSArray* asks;

// As described above, set by external users
@property(nonatomic, retain)NSNumber* bidInclusionDifferential;
@property(nonatomic, retain)NSNumber* askInclusionDifferential;

// Set by external users, whether or not to do a 1x,2,3x zoom of graphing
@property(nonatomic) NSInteger zoomLevel;

// Chart a sampling TTDepthViewChartingProcedureSampling or chart all orders TTDepthViewChartingProcedureAllOrders
@property(nonatomic)TTVerticalOBViewChartingProcedure chartingProcedure;

// Whether or not the current allBids/Allasks arrays have been processed
@property(nonatomic)BOOL needsCalibration;

// Process the allBids/AllAsks arrays
-(void)processData;

@end
