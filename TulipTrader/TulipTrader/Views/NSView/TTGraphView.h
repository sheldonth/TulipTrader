//
//  TTGraphView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/9/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTGoxCurrency.h"
#import <CorePlot/CorePlot.h>

typedef enum {
    TTGraphViewDateRangeNone = 0,
    TTGraphViewDateRangeOneHour,
    TTGraphViewDateRangeOneDay,
    TTGraphViewDateRangeOneMonth,
    TTGraphViewDateRangeThreeMonths,
    TTGraphViewDateRangeSixMonths,
    TTGraphViewDateRangeYearToDate,
    TTGraphViewDateRangeOneYear,
    TTGraphViewDateRangeAll
}TTGraphViewDateRange;

@interface TTGraphView : NSView <CPTScatterPlotDataSource, CPTScatterPlotDelegate>

@property(nonatomic)TTGoxCurrency currency;
@property(nonatomic)TTGraphViewDateRange selectedDateRange;
@end
