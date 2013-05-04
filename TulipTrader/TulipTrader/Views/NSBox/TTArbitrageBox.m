//
//  TTArbitrageBox.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/1/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTArbitrageBox.h"
#import "TTTextView.h"
#import "TTGoxPrivateMessageController.h"
#import "RUConstants.h"
#import "Ticker.h"
#import "Tick.h"
#import "TTGoxCurrency.h"
#import "TTAppDelegate.h"

@interface TTArbitrageBox ()

@property(nonatomic, retain)TTTextView* tradeTitle;
@property(nonatomic, weak)NSManagedObjectContext* appDelegateContext;
@property(nonatomic, retain)TTTextView* arbDeltaTitle;
@property(nonatomic, retain)TTTextView* deltaBtcTitle;

@end

@implementation TTArbitrageBox

#pragma mark - public method

#define kUnitsOfBitcoinBase 1

-(void)arbitrate // literally, the sexiest method name I've ever written. Just makes me wanna fuckkkinnggg uncze.
{
//    [_tradeTitle setString:RUStringWithFormat(@"%@%@", stringFromCurrency(_arbitrageStackCurrency), stringFromCurrency(_deltaCurrency))];
    // Order of operations, load latest ticker for each value.
    // calculate is bitcoin -> stack -> delta -> bitcoin is greater than 1.0 ?
    NSFetchRequest* fr_stack = [NSFetchRequest fetchRequestWithEntityName:@"Ticker"];
    [fr_stack setPredicate:[NSPredicate predicateWithFormat:@"channel_name == %@", bitcoinTickerChannelNameForCurrency(_arbitrageStackCurrency)]];
    [fr_stack setFetchLimit:1];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO];
    [fr_stack setSortDescriptors:@[sortDescriptor]];
    
    NSFetchRequest* fr_delta = [NSFetchRequest fetchRequestWithEntityName:@"Ticker"];
    [fr_delta setPredicate:[NSPredicate predicateWithFormat:@"channel_name == %@", bitcoinTickerChannelNameForCurrency(_arbitrageStackCurrency)]];
    [fr_delta setFetchLimit:1];
    [fr_delta setSortDescriptors:@[sortDescriptor]];

    NSError* e = nil;
    NSArray* stackTicker = [_appDelegateContext executeFetchRequest:fr_stack error:&e];
    if (e) @throw e;
    NSArray* deltaTicker = [_appDelegateContext executeFetchRequest:fr_delta error:&e];
    if (e) @throw e;
    
}

-(void)tickerRecorded:(NSNotification*)sender
{
    Ticker* t = [[sender userInfo]objectForKey:@"Ticker"];
    if ([t.channel_name isEqualToString:bitcoinTickerChannelNameForCurrency(_arbitrageStackCurrency)] || [t.channel_name isEqualToString:bitcoinTickerChannelNameForCurrency(_deltaCurrency)])
        [self arbitrate];
}

-(NSColor*)colorWithHexString:(NSString*)string
{
    unsigned int value = 0;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    if ([[string substringToIndex:2] isEqualToString:@"0x"] && string.length == 8)
        [scanner setScanLocation:2];
    [scanner scanHexInt:&value];
    
    return [NSColor colorWithDeviceRed:((float)((value & 0xFF0000) >> 16))/255.0
                                 green:((float)((value & 0xFF00) >> 8))/255.0
                                  blue:((float)(value & 0xFF))/255.0
                                 alpha:1.0];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:TTCurrencyUpdateNotificationString];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAppDelegateContext:[(TTAppDelegate*)[[NSApplication sharedApplication]delegate]managedObjectContext]];
        
        _bitcoinBase = TTGoxCurrencyBTC; // weird line of code, but neccesary
        [self setBorderColor:[self colorWithHexString:@"cccccc"]];
        [self setBorderType:NSLineBorder];
//        [self setFillColor:[NSColor blackColor]];
        [self setBorderWidth:1.f];
        [self setBoxType:NSBoxCustom];
        
        [self setTradeTitle:[TTTextView new]];
        [_tradeTitle setBackgroundColor:[NSColor redColor]];
        [self.contentView addSubview:_tradeTitle];
        
        [self setArbDeltaTitle:[TTTextView new]];
        [_arbDeltaTitle setBackgroundColor:[NSColor greenColor]];
        [self.contentView addSubview:_arbDeltaTitle];
        
        [self setDeltaBtcTitle:[TTTextView new]];
        [_deltaBtcTitle setBackgroundColor:[NSColor blueColor]];
        [self.contentView addSubview:_deltaBtcTitle];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tickerRecorded:) name:TTCurrencyUpdateNotificationString object:nil];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
//    [[NSColor orangeColor] setFill];
//    NSRectFill(dirtyRect);
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [_tradeTitle setFrame:(NSRect){0,CGRectGetHeight(frameRect) - 50, CGRectGetWidth(frameRect), 40}];
}

@end
