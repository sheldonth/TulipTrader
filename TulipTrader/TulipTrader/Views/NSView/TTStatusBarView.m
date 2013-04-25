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

@interface TTStatusBarView ()

@property(nonatomic, retain)TTTextView* connectionStateTextView;

@property(nonatomic, retain)TTGoxSocketController* webSocket;

@end

@implementation TTStatusBarView

static NSString* TT_NOTCONNECTED_STRING;
static NSString* TT_CONNECTED_STRING;
static NSString* TT_CONNECTING_STRING;
static NSString* TT_FAILED_STRING;
static NSString* TT_NONE_STRING;

static NSFont* TT_TYPEWRITER_FONT;

#define TTStatusBarContentLeftOffset 10.f

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
    switch (state) {
        case TTGoxSocketConnectionStateConnected:
            [_connectionStateTextView setString:TT_CONNECTED_STRING];
            break;
            
        case TTGoxSocketConnectionStateConnecting:
            [_connectionStateTextView setString:TT_CONNECTING_STRING];
            break;
            
        case TTGoxSocketConnectionStateNone:
            [_connectionStateTextView setString:TT_NONE_STRING];
            break;
            
        case TTGoxSocketConnectionStateFailed:
            [_connectionStateTextView setString:TT_FAILED_STRING];
            break;
            
        case TTGoxSocketConnectionStateNotConnected:
            [_connectionStateTextView setString:TT_NOTCONNECTED_STRING];
            break;
        }
    [_connectionStateTextView setNeedsDisplay:YES];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _connectionStateTextView = [[TTTextView alloc]initWithFrame:CGRectZero];
        [_connectionStateTextView setBackgroundColor:[NSColor clearColor]];
        [_connectionStateTextView setString:TT_NOTCONNECTED_STRING];
        [_connectionStateTextView setFont:TT_TYPEWRITER_FONT];
        [self addSubview:_connectionStateTextView];
        
        _webSocket = [TTGoxSocketController sharedInstance];
        
        [_webSocket addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [_connectionStateTextView setFrame:(NSRect){TTStatusBarContentLeftOffset, CGRectGetHeight(frameRect) - 65, 185, 60}];
}   

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
}

// If you invoke display manually, it invokes layout and layout invokes updateConstraints.

@end
