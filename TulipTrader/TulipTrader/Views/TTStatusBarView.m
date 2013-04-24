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

@interface TTStatusBarView ()

@property(nonatomic, retain)NSTextView* connectionStateTextView;
@property(nonatomic, retain)NSTextStorage* connectionStateTextStorage;

@property(nonatomic, retain)TTGoxSocketController* webSocket;

@end

@implementation TTStatusBarView

static NSString* TT_NOTCONNECTED_STRING;
static NSString* TT_CONNECTED_STRING;
static NSString* TT_CONNECTING_STRING;
static NSString* TT_FAILED_STRING;
static NSString* TT_NONE_STRING;

+(void)initialize
{
    if (self == [TTStatusBarView class])
    {
        TT_NOTCONNECTED_STRING = NSLocalizedString(@"Not Connected", @"TT_NOTCONNECTED_STRING");
        TT_CONNECTED_STRING = NSLocalizedString(@"Connected", @"TT_CONNECTED_STRING");
        TT_CONNECTING_STRING = NSLocalizedString(@"Connecting", @"TT_CONNECTING_STRING");
        TT_FAILED_STRING = NSLocalizedString(@"Failed", @"TT_FAILED_STRING");
        TT_NONE_STRING = NSLocalizedString(@"No State Available", @"TT_FAILED_NONE");
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    TTGoxSocketConnectionState state = (TTGoxSocketConnectionState)[[change objectForKey:@"new"]intValue];
    switch (state) {
        case TTGoxSocketConnectionStateConnected:
            [_connectionStateTextStorage.mutableString setString:TT_CONNECTED_STRING];
            break;
            
        case TTGoxSocketConnectionStateConnecting:
            [_connectionStateTextStorage.mutableString setString:TT_CONNECTING_STRING];
            break;
            
        case TTGoxSocketConnectionStateNone:
            [_connectionStateTextStorage.mutableString setString:TT_NONE_STRING];
            break;
            
        case TTGoxSocketConnectionStateFailed:
            [_connectionStateTextStorage.mutableString setString:TT_FAILED_STRING];
            break;
            
        case TTGoxSocketConnectionStateNotConnected:
            [_connectionStateTextStorage.mutableString setString:TT_NOTCONNECTED_STRING];
            break;
        }
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _connectionStateTextStorage = [[NSTextStorage alloc]initWithString:TT_NOTCONNECTED_STRING];
        
        NSLayoutManager* layoutManager = [[NSLayoutManager alloc]init];
        
        [_connectionStateTextStorage addLayoutManager:layoutManager];
        
        NSTextContainer* textContainer = [[NSTextContainer alloc]initWithContainerSize:(NSSize){85, 45}];
        
        [layoutManager addTextContainer:textContainer];
    
        _connectionStateTextView = [[NSTextView alloc]initWithFrame:(NSRect){5, 5, 85, 45} textContainer:textContainer];
        
        [_connectionStateTextView setBackgroundColor:[NSColor brownColor]];
        
        [self addSubview:_connectionStateTextView];
        
        _webSocket = [TTGoxSocketController sharedInstance];
        
        [_webSocket addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
}

-(void)layout
{
    [super layout];
    RUDLog(@"Layout Status bar frame: %@", NSStringFromRect(self.frame));
    [_connectionStateTextView setFrame:(NSRect){5, 5, 85, 40}];
}

// If you invoke display manually, it invokes layout and layout invokes updateConstraints.

@end
