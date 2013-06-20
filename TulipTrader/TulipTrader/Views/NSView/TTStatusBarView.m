//
//  TTStatusBarView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/5/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTStatusBarView.h"
#import "TTFrameConstants.h"
#import "RUConstants.h"
#import "TTGoxSocketController.h"
#import "TTTextView.h"
#import "TTCurrencyBox.h"
#import "TTGoxCurrencyController.h"
#import "TTGoxCurrency.h"
#import "NSColor+Hex.h"

@interface TTStatusBarView ()

@property(nonatomic, retain)NSMutableArray* currencyBoxes;

NSString* socketStateStringForConnectionState (TTGoxSocketConnectionState state);

@end

@implementation TTStatusBarView

static NSString* TT_NOTCONNECTED_STRING;
static NSString* TT_CONNECTED_STRING;
static NSString* TT_CONNECTING_STRING;
static NSString* TT_FAILED_STRING;
static NSString* TT_NONE_STRING;

static NSFont* TT_TYPEWRITER_FONT;
static NSFont* TT_TYPEWRITER_FONT_SMALL;

#define TTStatusBarContentLeftOffset 10.f
#define TTStatusBarContentBottomOffset 5.f

#define TTCurrencyBoxWidth 160.f
#define TTCurrencyBoxHeight 100.f

+(void)initialize
{
    if (self == [TTStatusBarView class])
    {
        TT_NOTCONNECTED_STRING = NSLocalizedString(@"Socket: Closed", @"TT_NOTCONNECTED_STRING");
        TT_CONNECTED_STRING = NSLocalizedString(@"Socket: Open", @"TT_CONNECTED_STRING");
        TT_CONNECTING_STRING = NSLocalizedString(@"Socket: Connecting", @"TT_CONNECTING_STRING");
        TT_FAILED_STRING = NSLocalizedString(@"Socket: Failed", @"TT_FAILED_STRING");
        TT_NONE_STRING = NSLocalizedString(@"No State Available", @"TT_FAILED_NONE");
        TT_TYPEWRITER_FONT_SMALL = [NSFont fontWithName:@"American Typewriter" size:14.f];
        TT_TYPEWRITER_FONT = [NSFont fontWithName:@"American Typewriter" size:22.f];
    }
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _currencyBoxes = [NSMutableArray array];
        
        [[TTGoxCurrencyController activeCurrencys] enumerateObjectsUsingBlock:^(NSString* currencyKey, NSUInteger idx, BOOL *stop) {
            TTCurrencyBox* bx = [TTCurrencyBox new];
            [bx setCurrency:currencyFromString(currencyKey)];
            [self addSubview:bx];
            [_currencyBoxes addObject:bx];
        }];
        
        CGFloat boxSpace = floorf(CGRectGetWidth(frame) / [TTGoxCurrencyController activeCurrencys].count);
        [_currencyBoxes enumerateObjectsUsingBlock:^(TTCurrencyBox* box, NSUInteger idx, BOOL *stop) {
            [box setFrame:(NSRect){((boxSpace / 2) - (TTCurrencyBoxWidth / 2)) + (boxSpace * (idx % 8)), TTStatusBarContentBottomOffset + ((idx / 8) * (TTCurrencyBoxHeight + 20)), TTCurrencyBoxWidth, TTCurrencyBoxHeight}];
        }];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
}

NSString* socketStateStringForConnectionState (TTGoxSocketConnectionState state)
{
    switch (state) {
        case TTGoxSocketConnectionStateConnected:
            return TT_CONNECTED_STRING;
            break;
            
        case TTGoxSocketConnectionStateConnecting:
            return TT_CONNECTING_STRING;
            break;
            
        case TTGoxSocketConnectionStateNone:
            return TT_NONE_STRING;
            break;
            
        case TTGoxSocketConnectionStateFailed:
            return TT_FAILED_STRING;
            break;
            
        case TTGoxSocketConnectionStateNotConnected:
            return TT_NOTCONNECTED_STRING;
            break;
    }
}

@end
