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
#import "TTOERatesController.h"

#define ABBoxPrimaryTitleHeight 40
#define ABBoxSecondaryTitleHeight 60
#define ABBoxThirdTitleHeight 40

static NSFont* currencyLabelFont;
static NSFont* zedFont;

@interface TTArbitrageBox ()

@property(nonatomic, weak)NSManagedObjectContext* appDelegateContext;
@property(nonatomic, retain)TTTextView* primaryTitleLeft;
@property(nonatomic, retain)TTTextView* secondaryTitleLeft;
@property(nonatomic, retain)TTTextView* thirdTitleLeft;
@property(nonatomic, retain)TTOERatesController* oeRatesController;

@end

@implementation TTArbitrageBox

#pragma mark - public method

#define kUnitsOfBitcoinBase 1.f

+(void)initialize
{
    if (self == [TTArbitrageBox class])
    {
        currencyLabelFont = [NSFont fontWithName:@"Avenir Next Condensed" size:12.f];
        zedFont = [NSFont fontWithName:@"Geneva-Bold" size:12.f];
    }
}

-(void)updateForZed:(double)zed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (zed > 1)
            [self setBorderColor:[self colorWithHexString:@"216C2A"]];
        else
            [self setBorderColor:[self colorWithHexString:@"cccccc"]];
    });
}

-(void)arbitrate // literally, the sexiest method name I've ever written. Just makes me wanna fuckkkinnggg uncze.
{
//    [_tradeTitle setString:RUStringWithFormat(@"%@%@", stringFromCurrency(_arbitrageStackCurrency), stringFromCurrency(_deltaCurrency))];
    // Order of operations, load latest ticker for each value.
    // calculate is bitcoin -> stack -> delta -> bitcoin is greater than 1.0 ?
    
    [_primaryTitleLeft setString:RUStringWithFormat(@"%@ %@ %@", stringFromCurrency(_bitcoinBase), stringFromCurrency(_alphaNodeCurrency), stringFromCurrency(_deltaNodeCurrency))];
    
    NSFetchRequest* alphaCurrencyFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Ticker"];
    [alphaCurrencyFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"channel_name == %@", bitcoinTickerChannelNameForCurrency(_alphaNodeCurrency)]];
    [alphaCurrencyFetchRequest setFetchLimit:1];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO];
    [alphaCurrencyFetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSFetchRequest* deltaCurrencyFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Ticker"];
    [deltaCurrencyFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"channel_name == %@", bitcoinTickerChannelNameForCurrency(_deltaNodeCurrency)]];
    [deltaCurrencyFetchRequest setFetchLimit:1];
    [deltaCurrencyFetchRequest setSortDescriptors:@[sortDescriptor]];

    NSError* e = nil;
    NSArray* alphaCurrencyTickerArray = [_appDelegateContext executeFetchRequest:alphaCurrencyFetchRequest error:&e];
    if (e) @throw e;
    NSArray* deltaCurrencyTickerArray = [_appDelegateContext executeFetchRequest:deltaCurrencyFetchRequest error:&e];
    if (e) @throw e;
    
    Ticker* alphaTicker = [alphaCurrencyTickerArray objectAtIndex:0];
    Ticker* deltaTicker = [deltaCurrencyTickerArray objectAtIndex:0];
    
    double alphaNodeDouble = kUnitsOfBitcoinBase * alphaTicker.buy.value.doubleValue;
//    [_primaryTitleLeft setString:RUStringWithFormat(@"%f", alphaNodeDouble)];
    
    NSNumber* alphaDeltaBuyPrice = [_oeRatesController priceForCurrency:_deltaNodeCurrency inBaseCurrency:_alphaNodeCurrency];
    
    double deltaNodeComputed = alphaNodeDouble * alphaDeltaBuyPrice.doubleValue;
    
    double zed = deltaNodeComputed / deltaTicker.sell.value.doubleValue;
    
    [_secondaryTitleLeft setString:RUStringWithFormat(@"%f", zed)];
//    [_thirdTitleLeft setString:RUStringWithFormat(@"%f", zed)];
    [self updateForZed:zed];
}

-(void)tickerRecorded:(NSNotification*)sender
{
    Ticker* t = [[sender userInfo]objectForKey:@"Ticker"];
    if ([t.channel_name isEqualToString:bitcoinTickerChannelNameForCurrency(_alphaNodeCurrency)] || [t.channel_name isEqualToString:bitcoinTickerChannelNameForCurrency(_deltaNodeCurrency)])
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
        [self setBorderWidth:1.5f];
        [self setBoxType:NSBoxCustom];
        
        [self setPrimaryTitleLeft:[TTTextView new]];
        [_primaryTitleLeft setBackgroundColor:[NSColor clearColor]];
        [_primaryTitleLeft setAlignment:NSCenterTextAlignment];
        [_primaryTitleLeft setFont:currencyLabelFont];
        [_primaryTitleLeft setEditable:NO];
        [self.contentView addSubview:_primaryTitleLeft];
        
        [self setSecondaryTitleLeft:[TTTextView new]];
        [_secondaryTitleLeft setAlignment:NSCenterTextAlignment];
        [_secondaryTitleLeft setBackgroundColor:[NSColor clearColor]];
        [_secondaryTitleLeft setEditable:NO];
        [self.contentView addSubview:_secondaryTitleLeft];
        
        [self setThirdTitleLeft:[TTTextView new]];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tickerRecorded:) name:TTCurrencyUpdateNotificationString object:nil];
    
        [self setOeRatesController:[TTOERatesController sharedInstance]];
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
    [_primaryTitleLeft setFrame:(NSRect){0,CGRectGetHeight(frameRect) - 50, CGRectGetWidth(frameRect), ABBoxPrimaryTitleHeight}];
    [_secondaryTitleLeft setFrame:(NSRect){0, CGRectGetHeight(frameRect) - (70 + _primaryTitleLeft.frame.size.height), CGRectGetWidth(frameRect), ABBoxSecondaryTitleHeight}];
//    [_thirdTitleLeft setFrame:(NSRect){0, CGRectGetHeight(frameRect) - (50 + _primaryTitleLeft.frame.size.height + _secondaryTitleLeft.frame.size.height), CGRectGetWidth(frameRect), ABBoxThirdTitleHeight}];
}

@end
