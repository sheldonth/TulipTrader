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

@interface TTStatusBarView ()

@property(nonatomic, retain)TTTextView* connectionStateTextView;
@property(nonatomic, retain)TTGoxSocketController* webSocket;
@property(nonatomic, retain)NSMutableArray* currencyBoxes;
@property(nonatomic, retain)NSScrollView* scrollView;

NSString* socketStateStringForConnectionState (TTGoxSocketConnectionState state);

@end

@implementation TTStatusBarView

static NSString* TT_NOTCONNECTED_STRING;
static NSString* TT_CONNECTED_STRING;
static NSString* TT_CONNECTING_STRING;
static NSString* TT_FAILED_STRING;
static NSString* TT_NONE_STRING;

static NSFont* TT_TYPEWRITER_FONT;

#define TTStatusBarContentLeftOffset 10.f
#define TTStatusBarContentBottomOffset 10.f

#define TTCurrencyBoxWidth 100.f
#define TTCurrencyBoxHeight 70.f


+(void)initialize
{
    if (self == [TTStatusBarView class])
    {
        TT_NOTCONNECTED_STRING = NSLocalizedString(@"Not Connected", @"TT_NOTCONNECTED_STRING");
        TT_CONNECTED_STRING = NSLocalizedString(@"Connected", @"TT_CONNECTED_STRING");
        TT_CONNECTING_STRING = NSLocalizedString(@"Connecting", @"TT_CONNECTING_STRING");
        TT_FAILED_STRING = NSLocalizedString(@"Failed", @"TT_FAILED_STRING");
        TT_NONE_STRING = NSLocalizedString(@"No State Available", @"TT_FAILED_NONE");
        TT_TYPEWRITER_FONT = [NSFont fontWithName:@"American Typewriter" size:22.f];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    TTGoxSocketConnectionState state = (TTGoxSocketConnectionState)[[change objectForKey:@"new"]intValue];
    NSString* stateStr = socketStateStringForConnectionState(state);
    if (![[_connectionStateTextView string]isEqualToString:stateStr])
        [_connectionStateTextView setString:stateStr];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _webSocket = [TTGoxSocketController sharedInstance];
        
        _connectionStateTextView = [[TTTextView alloc]initWithFrame:CGRectZero];
        [_connectionStateTextView setBackgroundColor:[NSColor clearColor]];
        [_connectionStateTextView setString:socketStateStringForConnectionState(_webSocket.isConnected)];
        [_connectionStateTextView setFont:TT_TYPEWRITER_FONT];
        [self addSubview:_connectionStateTextView];
        
        _scrollView = [[NSScrollView alloc]initWithFrame:CGRectZero];
        [_scrollView setDocumentView:[NSView new]];
//        [_scrollView.documentView setBackgroundColor:[NSColor blueColor]];
        [self addSubview:_scrollView];
        
        [_webSocket addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew context:nil];
        
        // Enumerate the active currencies, and add a currency box for each, set their frames in the status bar's setframe method
        
        _currencyBoxes = [NSMutableArray array];
        
        [[TTGoxCurrencyController activeCurrencys] enumerateObjectsUsingBlock:^(NSString* currencyKey, NSUInteger idx, BOOL *stop) {
            TTCurrencyBox* bx = [TTCurrencyBox new];
            [bx setCurrency:currencyFromString(currencyKey)];
            [self addSubview:bx];
            [_currencyBoxes addObject:bx];
        }];
    }
    return self;
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [_connectionStateTextView setFrame:(NSRect){TTStatusBarContentLeftOffset, CGRectGetHeight(frameRect) - 65, 185, 60}];
    [_scrollView setFrame:(NSRect){0, 0, CGRectGetWidth(frameRect), TTCurrencyBoxHeight}];
    CGFloat boxSpace = CGRectGetWidth(frameRect) / 8;
    [_currencyBoxes enumerateObjectsUsingBlock:^(TTCurrencyBox* box, NSUInteger idx, BOOL *stop) {
        [box setFrame:(NSRect){((boxSpace / 2) - (TTCurrencyBoxWidth / 2)) + (boxSpace * (idx % 8)), TTStatusBarContentBottomOffset + ((idx / 8) * (TTCurrencyBoxHeight + 20)), TTCurrencyBoxWidth, TTCurrencyBoxHeight}];
    }];
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

// If you invoke display manually, it invokes layout and layout invokes updateConstraints.

@end
