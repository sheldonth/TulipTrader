//
//  TTStatusBox.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/3/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTStatusBox.h"
#import "NSColor+Hex.h"
#import "TTTicker.h"
#import "RUConstants.h"
#import "TTTrade.h"
#import "TTDepthOrder.h"
#import "JNWLabel.h"
#import "TTTradesWindow.h"

@interface TTStatusBox()
{
    BOOL drawsBackground;
}
@property(nonatomic, retain)NSString* labelingGroup1Text;
@property(nonatomic) CGFloat labelingGroup1Width;
@property(nonatomic, retain) NSMutableDictionary* labelingProperties1Dictionary;
@property(nonatomic, retain)NSString* labelingGround2Text;
@property(nonatomic) CGFloat labelingGroup2Width;
@property(nonatomic, retain) NSMutableDictionary* labelingProperties2Dictionary;

@property(nonatomic, retain)NSMutableArray* broadcastTrades;
@property(nonatomic, retain)JNWLabel* fadingDepthEventLabel;
@property(nonatomic, retain)JNWLabel* fadingTradeEventLabel;
@property(nonatomic, retain)NSTrackingArea* trackingArea;

@property(nonatomic, strong)TTTradesWindow* tradesWindow;

@end

@implementation TTStatusBox

static NSFont* statusBarFont;

+(void)initialize
{
    if (self == [TTStatusBox class])
    {
        statusBarFont = [NSFont fontWithName:@"Menlo" size:16.f];
    }
}

#pragma mark - C Helper Methods

NSString* englishVerbForDepthOrderAction(TTDepthOrderAction action)
{
    NSString* val;
    switch (action) {
        case TTDepthOrderActionAdd:
            val = @"Added";
            break;
            
        case TTDepthOrderActionRemove:
            val = @"Removed";
            break;
            
        case TTDepthOrderActionNone:
            val = @"";
            
        default:
            val = @"";
            break;
    }
    return val;
}

NSString* englishNounForDepthOrderType(TTDepthOrderType type)
{
    NSString* str;
    switch (type) {
        case TTDepthOrderTypeBid:
            str = @"BID";
            break;
            
        case TTDepthOrderTypeAsk:
            str = @"ASK";
            break;
        
        case TTDepthOrderTypeNone:
            str = @"ERR";
            RUDLog(@"No depth order type");
            break;
            
        default:
            break;
    }
    return str;
}

#pragma mark - nswindowdelegate methods

-(void)windowWillClose:(NSNotification *)notification
{

}
    
-(NSRect)depthButtonRect
{
    return (NSRect){_labelingGroup1Width + 1.f, 0, CGRectGetWidth(_fadingTradeEventLabel.frame), CGRectGetHeight(self.frame)};
}

#pragma mark - ttorderbook delegates

-(void)orderBook:(TTOrderBook *)orderBook hasNewConnectionState:(TTOrderBookConnectionState)connectionState
{
    @synchronized(self.labelingProperties1Dictionary)
    {
        switch (connectionState) {
            case TTOrderBookConnectionStateNone:
                [self setLabelingGroup1Text:@""];
                [self.labelingProperties1Dictionary setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
                break;
                
            case TTOrderBookConnectionStateSocketConnected:
                [self setLabelingGroup1Text:@"Connected"];
                [self.labelingProperties1Dictionary setObject:[NSColor colorWithHexString:@"006400"] forKey:NSForegroundColorAttributeName];
                break;
                
            case TTOrderBookConnectionStateSocketConnecting:
                [self setLabelingGroup1Text:@"Connecting"];
                [self.labelingProperties1Dictionary setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
                break;
                
            case TTOrderBookConnectionStateSocketDisconnected:
                [self setLabelingGroup1Text:@"Disconnected"];
                [self.labelingProperties1Dictionary setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
                break;
                
            case TTOrderBookConnectionStateSocketUnavailable:
                [self.labelingProperties1Dictionary setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
                [self setLabelingGroup1Text:@"N/A"];
                break;
                
            default:
                break;
        }
        [self setNeedsDisplay:YES];
    }
}

-(void)orderBook:(TTOrderBook *)orderBook hasNewEvent:(id)event
{
    if ([event class] == [TTTrade class])
    {
        TTTrade* trade = (TTTrade*)event;
        
        [self.broadcastTrades addObject:event];
        
        __block double sum = 0;
        __block double count = 0;
        
        [[self.broadcastTrades.reverseObjectEnumerator allObjects]enumerateObjectsUsingBlock:^(TTTrade* obj, NSUInteger idx, BOOL *stop) {
            if (obj.trade_type != trade.trade_type)
            {
                *stop = YES;
            }
            else
            {
                sum = sum + obj.amount.doubleValue;
                count++;
            }
        }];
        
        NSString* tradeStr = RUStringWithFormat(@"%.5f at %.5f %@ : %.0f(%.0f)", trade.amount.floatValue, trade.price.floatValue, stringFromCurrency(currencyFromNumber(trade.currency)), sum, count);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.fadingTradeEventLabel setText:tradeStr];
        });
    }
    else if ([event class] == [TTTicker class])
    {
//        RUDLog(@"Ticker");
    }
    else if ([event class] == [TTDepthOrder class])
    {
        NSString* assignmentString;
        TTDepthOrder* dOrder = (TTDepthOrder*)event;
        switch ([dOrder depthDeltaType]) {
            case TTDepthOrderTypeAsk:
                assignmentString = RUStringWithFormat(@"%@ %@ for %.5f at %.5f", englishVerbForDepthOrderAction(dOrder.depthDeltaAction), englishNounForDepthOrderType(dOrder.depthDeltaType), dOrder.amount.floatValue, dOrder.price.floatValue);
                break;
            
            case TTDepthOrderTypeBid:
                assignmentString = RUStringWithFormat(@"%@ %@ for %.5f at %.5f", englishVerbForDepthOrderAction(dOrder.depthDeltaAction), englishNounForDepthOrderType(dOrder.depthDeltaType), dOrder.amount.floatValue, dOrder.price.floatValue);
                break;
                
            case TTDepthOrderTypeNone:
                assignmentString = @"NO ORDERBOOK MEMBERSHIP";
                break;
            
            default:
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.fadingDepthEventLabel setText:assignmentString];
        });
    }
    else
        RUDLog(@"Unrecognized untyped class");
    
}

-(void)mouseDown:(NSEvent *)theEvent
{
    NSPoint eventLocation = [theEvent locationInWindow];
    NSPoint convertedPt = [self convertPoint:eventLocation fromView:nil];
    
    if (CGRectContainsPoint([self depthButtonRect], convertedPt))
    {
        drawsBackground = YES;
        [self setNeedsDisplay:YES];
    }
}

-(void)mouseUp:(NSEvent *)theEvent
{
    NSPoint eventLocation = [theEvent locationInWindow];
    NSPoint convertedPt = [self convertPoint:eventLocation fromView:nil];
    if (CGRectContainsPoint([self depthButtonRect], convertedPt))
    {
        if (!self.tradesWindow)
        {
            [self setTradesWindow:[[TTTradesWindow alloc]initWithContentRect:(NSRect){20, 20, 300, 200} styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask) backing:NSBackingStoreBuffered defer:YES]];
            [self.tradesWindow setTitle:@"Trades"];
            [self.tradesWindow setReleasedWhenClosed:NO];
            [self.tradesWindow setDelegate:self];
        }
        [self.tradesWindow makeKeyAndOrderFront:self];
    }
    drawsBackground = NO;
    [self setNeedsDisplay:YES];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBorderType:NSLineBorder];
        [self setTitlePosition:NSNoTitle];
        [self setBoxType:NSBoxCustom];
        [self setCornerRadius:2.f];
        [self setBorderWidth:2.f];
        [self setBorderColor:[NSColor lightGrayColor]];
        
        [self setLabelingGroup1Width:floorf(CGRectGetWidth(frame) / 8)];
        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSCenterTextAlignment];
        _labelingProperties1Dictionary = [NSMutableDictionary dictionaryWithDictionary:@{NSParagraphStyleAttributeName : style, NSFontAttributeName : statusBarFont}];
        _labelingProperties2Dictionary = [NSMutableDictionary dictionaryWithDictionary:@{NSParagraphStyleAttributeName : style, NSFontAttributeName : statusBarFont}];
        
        [self setFadingTradeEventLabel:[[JNWLabel alloc]initWithFrame:(NSRect){_labelingGroup1Width, 0, _labelingGroup1Width * 4, CGRectGetHeight([self.contentView frame])}]];
        [self.fadingTradeEventLabel setTextAlignment:NSCenterTextAlignment];
        [self.fadingTradeEventLabel setFont:statusBarFont];
        [self addSubview:_fadingTradeEventLabel];
        
        [self setFadingDepthEventLabel:[[JNWLabel alloc]initWithFrame:(NSRect){CGRectGetMaxX(self.fadingTradeEventLabel.frame), 0, _labelingGroup1Width * 3, CGRectGetHeight([self.contentView frame])}]];
        [self.fadingDepthEventLabel setTextAlignment:NSCenterTextAlignment];
        [self.fadingDepthEventLabel setFont:statusBarFont];
        [self addSubview:_fadingDepthEventLabel];
        
        [self setBroadcastTrades:[NSMutableArray array]];
        
        [self setTrackingArea:[[NSTrackingArea alloc]initWithRect:frame options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved+NSTrackingActiveInKeyWindow) owner:self userInfo:nil]];
        [self addTrackingArea:_trackingArea];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (drawsBackground)
    {
        [[NSColor whiteColor]set];
        NSRectFill([self depthButtonRect]);
    }
    [super drawRect:dirtyRect];
    
    [self.labelingGroup1Text drawInRect:(NSRect){0, 0, _labelingGroup1Width, CGRectGetHeight(self.frame) - 2} withAttributes:self.labelingProperties1Dictionary];
    NSBezierPath* bp = [NSBezierPath bezierPath];
    [bp moveToPoint:(NSPoint){_labelingGroup1Width, 0}];
    [bp lineToPoint:(NSPoint){_labelingGroup1Width, CGRectGetHeight(self.frame)}];
    [bp setLineWidth:2.f];
    [[NSColor lightGrayColor]set];
    [bp stroke];
    
    [bp moveToPoint:(NSPoint){_labelingGroup1Width * 5, 0}];
    [bp lineToPoint:(NSPoint){_labelingGroup1Width * 5, CGRectGetHeight(self.frame)}];
    [bp setLineWidth:2.f];
    [[NSColor lightGrayColor]set];
    [bp stroke];
}

@end
