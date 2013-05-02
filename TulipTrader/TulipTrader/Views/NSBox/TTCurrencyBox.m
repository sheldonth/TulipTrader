//
//  TTCurrencyBox.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/25/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTCurrencyBox.h"
#import "TTTextView.h"
#import "TTGoxCurrency.h"
#import "TTAppDelegate.h"
#import "RUConstants.h"
#import "Ticker.h"
#import "Tick.h"
#import "TTGoxPrivateMessageController.h"

@interface TTCurrencyBox ()
@property (nonatomic, retain) NSImageView* flagImage;
@property (nonatomic, retain) TTTextView* sellPriceText;
@property (nonatomic, retain) TTTextView* buyPriceText;
@property (nonatomic, retain) NSFetchRequest* unifiedFetchRequest;
@property (nonatomic, retain) NSTimer* refreshTimer;
@property (assign) NSManagedObjectContext* appDelegateContext;
@property (nonatomic, retain) TTTextView* buyWordText;
@property (nonatomic, retain) TTTextView* sellWordText;
@end

@implementation TTCurrencyBox

static NSFont* titleFont;
static NSFont* buyFont;
static NSFont* sellFont;
static NSFont* buySellLabelsFont;

+(void)initialize
{
    titleFont = [NSFont fontWithName:@"American Typewriter" size:10.f];
    buyFont = [NSFont fontWithName:@"Helvetica-Bold" size:14.f];
    sellFont = [NSFont fontWithName:@"Helvetica-Bold" size:14.f];
    buySellLabelsFont = [NSFont fontWithName:@"Avenir Next" size:12.f];
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

-(void)reloadTicker:(NSNotification*)sender
{
    Ticker* ticker = [sender.userInfo objectForKey:@"Ticker"];
    TTGoxCurrency currency = currencyFromNumber(ticker.buy.currency); // @SHELDON ITS BAD FORM THAT I'M ASSUMING TO USE THE BUY TICK CURRENCY!
    if (currency == self.currency)
        [self runQuery];
}

-(void)runQuery
{
    NSError* e = nil;
    NSArray* latestTicker = [_appDelegateContext executeFetchRequest:_unifiedFetchRequest error:&e];
    if (e)
        {RUDLog(@"Error fetching latest ticker for channel: %@", bitcoinTickerChannelNameForCurrency(_currency));return;}
    if (latestTicker.count)
    {
        Ticker* ticker = [latestTicker lastObject];
        NSNumber* lastSell = [ticker.sell value];
        NSNumber* lastBuy = [ticker.buy value];
        [_sellPriceText setString:RUStringWithFormat(@"%@", stringShortenedForCurrencyBox(lastSell.stringValue))];
        [_buyPriceText setString:RUStringWithFormat(@"%@", stringShortenedForCurrencyBox(lastBuy.stringValue))];
    }
    else
    {
        [_buyPriceText setString:@"--.-----"];
        [_sellPriceText setString:@"--.-----"];
    }
}

-(void)setCurrency:(TTGoxCurrency)currency
{
    [self willChangeValueForKey:@"currency"];
    _currency = currency;
    [self setTitle:RUStringWithFormat(@"%@.BTC", stringFromCurrency(currency))];
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"channel_name == %@", bitcoinTickerChannelNameForCurrency(currency)];
    [self.unifiedFetchRequest setPredicate:pred];
    [self didChangeValueForKey:@"currency"];
    [self runQuery];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TTCurrencyUpdateNotificationString object:nil];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBorderWidth:2.f];
        [self setBorderColor:[NSColor blackColor]];
        [self setBorderType:NSBezelBorder];
        [self setBoxType:NSBoxPrimary];
        [self setFillColor:[self colorWithHexString:@"cccccc"]];
        [self setTitleFont:titleFont];
        
        [self setAppDelegateContext:[(TTAppDelegate*)[[NSApplication sharedApplication]delegate]managedObjectContext]];
        [self setUnifiedFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Ticker"]];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO];
        [_unifiedFetchRequest setSortDescriptors:@[sortDescriptor]];
        [_unifiedFetchRequest setFetchLimit:1];
        
        [self setSellPriceText:[TTTextView new]];
        [_sellPriceText setBackgroundColor:[NSColor clearColor]];
        [_sellPriceText setEditable:NO];
        [_sellPriceText setFont:sellFont];
        [self addSubview:_sellPriceText];
        [self setBuyPriceText:[TTTextView new]];
        [_buyPriceText setBackgroundColor:[NSColor clearColor]];
        [_buyPriceText setEditable:NO];
        [_buyPriceText setFont:buyFont];
        [self addSubview:_buyPriceText];
        
        [self setBuyWordText:[TTTextView new]];
        [_buyWordText setBackgroundColor:[NSColor clearColor]];
        [_buyWordText setEditable:NO];
        [_buyWordText setFont:buySellLabelsFont];
        [_buyWordText setTextColor:[self colorWithHexString:@"337147"]];
        [_buyWordText setString:@"Buy:"];
        [self addSubview:_buyWordText];
        
        [self setSellWordText:[TTTextView new]];
        [_sellWordText setBackgroundColor:[NSColor clearColor]];
        [_sellWordText setEditable:NO];
        [_sellWordText setFont:buySellLabelsFont];
        [_sellWordText setTextColor:[self colorWithHexString:@"f26c4f"]];
        [_sellWordText setString:@"Sell:"];
        [self addSubview:_sellWordText];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadTicker:) name:TTCurrencyUpdateNotificationString object:nil];
    }
    return self;
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [_buyPriceText setFrame:(NSRect){25, CGRectGetHeight(frameRect) - 60, 90, 30}];
    [_sellPriceText setFrame:(NSRect){25, CGRectGetHeight(frameRect) - 80, 90, 30}];
    [_sellWordText setFrame:(NSRect){-5, CGRectGetHeight(frameRect) - 76, 40, 25}];
    [_buyWordText setFrame:(NSRect){-5, CGRectGetHeight(frameRect) - 56, 40, 25}];
    [self setNeedsDisplay:YES];
}

NSString* stringShortenedForCurrencyBox(NSString* proposedVal)
{
    if (proposedVal.length < 10)
        return proposedVal;
    else
    {
        NSMutableString* s  = [NSMutableString stringWithString:proposedVal];
        return [s substringToIndex:10];
    }
}

@end
