//
//  TTStatusBarView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/5/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTStatusBarView.h"
#import "TTFrameConstants.h"
#import "RUConstants.h"
#import "TTGoxSocketController.h"
#import "TTTextView.h"
#import "TTCurrencyBox.h"
#import "TTGoxCurrencyController.h"
#import "TTGoxCurrency.h"
#import "TTMarketBox.h"

@interface TTStatusBarView ()

//@property(nonatomic, retain)TTTextView* connectionStateTextView;
//@property(nonatomic, retain)TTGoxSocketController* webSocket;
//@property(nonatomic, retain)NSScrollView* scrollView;
//@property(nonatomic, retain)TTTextView* lagStateTextView;
@property(nonatomic, retain)NSMutableArray* currencyBoxes;
@property(nonatomic, retain)TTMarketBox* goxMarketBox;
@property(nonatomic, retain)TTMarketBox* coinbaseMarketBox;

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
#define TTStatusBarContentBottomOffset 10.f

#define TTCurrencyBoxWidth 130.f
#define TTCurrencyBoxHeight 70.f

#pragma mark - lag delegate
-(void)lagObserved:(NSDictionary *)lagDict
{
    RUDLog(@"$");
}

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
        
        // Enumerate the active currencies, and add a currency box for each, set their frames in the status bar's setframe method
        
        _goxMarketBox = [TTMarketBox new];
        [self addSubview:_goxMarketBox];
        
        _coinbaseMarketBox = [TTMarketBox new];
        [self addSubview:_coinbaseMarketBox];
        
        _currencyBoxes = [NSMutableArray array];
        
        [[TTGoxCurrencyController activeCurrencys] enumerateObjectsUsingBlock:^(NSString* currencyKey, NSUInteger idx, BOOL *stop) {
            TTCurrencyBox* bx = [TTCurrencyBox new];
            [bx setCurrency:currencyFromString(currencyKey)];
            [self addSubview:bx];
            [_currencyBoxes addObject:bx];
        }];
        
        [[TTGoxPrivateMessageController sharedInstance]setLagDelegate:self];
    }
    return self;
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
//    [_connectionStateTextView setFrame:(NSRect){TTStatusBarContentLeftOffset, CGRectGetHeight(frameRect) - 65, 225, 60}];
//    [_lagStateTextView setFrame:(NSRect){TTStatusBarContentLeftOffset + 5, 70, 165, 25}];
    CGFloat boxSpace = CGRectGetWidth(frameRect) / 8;
    [_currencyBoxes enumerateObjectsUsingBlock:^(TTCurrencyBox* box, NSUInteger idx, BOOL *stop) {
        [box setFrame:(NSRect){((boxSpace / 2) - (TTCurrencyBoxWidth / 2)) + (boxSpace * (idx % 8)), TTStatusBarContentBottomOffset + ((idx / 8) * (TTCurrencyBoxHeight + 20)), TTCurrencyBoxWidth, TTCurrencyBoxHeight}];
    }];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor redColor] setFill];
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

// If you invoke display manually, it invokes layout and layout invokes updateConstraints.

@end
