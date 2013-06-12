//
//  TTCurrencyBox.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/25/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTCurrencyBox.h"
#import "TTTextView.h"
#import "TTGoxCurrency.h"
#import "TTAppDelegate.h"
#import "RUConstants.h"
#import "Ticker.h"
#import "Tick.h"
#import "TTGoxPrivateMessageController.h"
#import "NSColor+Hex.h"
#import "Trade.h"
#import "JNWLabel.h"

@interface TTCurrencyBox ()
@property (nonatomic, retain) NSImageView* flagImage;
@property (nonatomic, retain) TTTextView* sellPriceText;
@property (nonatomic, retain) TTTextView* buyPriceText;
@property (nonatomic, retain) NSFetchRequest* unifiedFetchRequest;
@property (nonatomic, retain) NSTimer* refreshTimer;
@property (assign) NSManagedObjectContext* appDelegateContext;
@property (nonatomic, retain) TTTextView* buyWordText;
@property (nonatomic, retain) TTTextView* sellWordText;
@property (nonatomic, retain) TTTextView* spreadLabel;
@property (nonatomic, retain) JNWLabel* tradeQtyLabel;
@property (nonatomic, retain) JNWLabel* tradeStrikePriceLabel;

NSUInteger numberOfLeadingCharactersToAffectForCurrency(TTGoxCurrency currency);

@end

@implementation TTCurrencyBox

static NSFont* titleFont;
static NSFont* buyFont;
static NSFont* sellFont;
static NSFont* buySellLabelsFont;
static NSFont* buySellFontForCurrencyLetters;
static NSFont* spreadFont;
static NSNumberFormatter* spreadNumberFormatter;
static NSColor* buyGreen;
static NSColor* sellRed;

+(void)initialize
{
    titleFont = [NSFont fontWithName:@"American Typewriter" size:10.f];
    buyFont = [NSFont fontWithName:@"Helvetica-Bold" size:14.f];
    sellFont = [NSFont fontWithName:@"Helvetica-Bold" size:14.f];
    buySellFontForCurrencyLetters = [NSFont fontWithName:@"Helvetica-Italic" size:10.f];
    buySellLabelsFont = [NSFont fontWithName:@"Didot-Bold" size:12.f];
    spreadFont = [NSFont fontWithName:@"Helvetica" size:12.f];
    spreadNumberFormatter = [NSNumberFormatter new];
    [spreadNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [spreadNumberFormatter setMaximumFractionDigits:0];
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

-(void)loadTrade:(NSNotification*)sender
{
    Trade* trade = [sender.userInfo objectForKey:@"Trade"];
    NSString* tradeQtyString;
    NSString* tradeStrikeString = RUStringWithFormat(@"@ %@%.5f", currencySymbolStringFromCurrency(currencyFromNumber(trade.currency)), trade.price.floatValue);
    
    if (trade.tradeType == TTGoxTradeTypeNone)
        return;
    else if (trade.tradeType == TTGoxTradeTypeBid)
        tradeQtyString = RUStringWithFormat(@"%.5fBTC bid [BUY]", trade.amount.floatValue);
    else if (trade.tradeType == TTGoxTradeTypeAsk)
        tradeQtyString = RUStringWithFormat(@"%.5fBTC ask [SELL]", trade.amount.floatValue);
    
    if (currencyFromNumber(trade.currency) == self.currency)
    {
     dispatch_async(dispatch_get_main_queue(), ^{
                [self.tradeQtyLabel setText:tradeQtyString];
                [self.tradeStrikePriceLabel setText:tradeStrikeString];
        });
    }
}

-(void)reloadTicker:(NSNotification*)sender
{
    Ticker* ticker = [sender.userInfo objectForKey:@"Ticker"];
    TTGoxCurrency currency = currencyFromNumber(ticker.buy.currency); // @SHELDON ITS BAD FORM THAT I'M ASSUMING TO USE THE BUY TICK CURRENCY!
    if (currency == self.currency)
    {
        NSNumber* lastSell = [ticker.sell value];
        NSNumber* lastBuy = [ticker.buy value];
        [_sellPriceText setString:RUStringWithFormat(@"%@%@",currencySymbolStringFromCurrency(_currency), stringShortenedForCurrencyBox(lastSell.stringValue))];
        [_buyPriceText setString:RUStringWithFormat(@"%@%@", currencySymbolStringFromCurrency(_currency), stringShortenedForCurrencyBox(lastBuy.stringValue))];
        
        double spread = (lastSell.doubleValue - lastBuy.doubleValue) * pow(10, 5);
        [self.spreadLabel setString:RUStringWithFormat(@"%@pips", [spreadNumberFormatter stringFromNumber:@(spread)])];
    }
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
        [_sellPriceText setString:RUStringWithFormat(@"%@%@",currencySymbolStringFromCurrency(_currency), stringShortenedForCurrencyBox(lastSell.stringValue))];
        [_buyPriceText setString:RUStringWithFormat(@"%@%@", currencySymbolStringFromCurrency(_currency), stringShortenedForCurrencyBox(lastBuy.stringValue))];
        
        double spread = (lastSell.doubleValue - lastBuy.doubleValue) * pow(10, 5);
        [self.spreadLabel setString:RUStringWithFormat(@"%@pips", [spreadNumberFormatter stringFromNumber:@(spread)])];
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
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TTGoxWebsocketTickerNotificationString object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TTGoxWebsocketTradeNotificationString object:nil];
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
        [self setFillColor:[NSColor colorWithHexString:@"545454"]];
        [self setFillColor:[NSColor whiteColor]];
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
        [self.contentView addSubview:_sellPriceText];
        
        [self setBuyPriceText:[TTTextView new]];
        [_buyPriceText setBackgroundColor:[NSColor clearColor]];
        [_buyPriceText setEditable:NO];
        [_buyPriceText setFont:buyFont];
        [self.contentView addSubview:_buyPriceText];
        
        [self setBuyWordText:[TTTextView new]];
        [_buyWordText setBackgroundColor:[NSColor clearColor]];
        [_buyWordText setEditable:NO];
        [_buyWordText setFont:buySellLabelsFont];
        [_buyWordText setTextColor:[NSColor blackColor]];
        [_buyWordText setString:@"Bid:"];
        [self.contentView addSubview:_buyWordText];
        
        [self setSellWordText:[TTTextView new]];
        [_sellWordText setBackgroundColor:[NSColor clearColor]];
        [_sellWordText setEditable:NO];
        [_sellWordText setFont:buySellLabelsFont];
        [_sellWordText setTextColor:[NSColor blackColor]];
        [_sellWordText setString:@"Ask:"];
        [self.contentView addSubview:_sellWordText];
        
        [self setSpreadLabel:[TTTextView new]];
        [_spreadLabel setBackgroundColor:[NSColor clearColor]];
        [_spreadLabel setEditable:NO];
        [_spreadLabel setAlignment:NSCenterTextAlignment];
        [_spreadLabel setFont:spreadFont];
        [_spreadLabel setTextColor:[NSColor blackColor]];
        [self.contentView addSubview:self.spreadLabel];
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadTicker:) name:TTGoxWebsocketTickerNotificationString object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadTrade:) name:TTGoxWebsocketTradeNotificationString object:nil];
    }
    return self;
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [_sellPriceText setFrame:(NSRect){25, CGRectGetHeight(frameRect) - 55, 120, 30}];
    [_sellWordText setFrame:(NSRect){-5, CGRectGetHeight(frameRect) - 52, 40, 25}];
    
    [_buyPriceText setFrame:(NSRect){25, CGRectGetHeight(frameRect) - 72, 120, 30}];
    [_buyWordText setFrame:(NSRect){-5, CGRectGetHeight(frameRect) - 69, 40, 25}];
    
    [_spreadLabel setFrame:(NSRect){0, CGRectGetHeight(frameRect) - 85, CGRectGetWidth([(NSView*)self.contentView frame]), 25}];
    
    if (!self.tradeQtyLabel) // JNWLabel isn't friendly to allocators other than initWithFrame:
    {
        [self setTradeQtyLabel:[[JNWLabel alloc]initWithFrame:(NSRect){0, CGRectGetMinY(_spreadLabel.frame) - 12, CGRectGetWidth([(NSView*)self.contentView frame]), 12}]];
        [_tradeQtyLabel setBackgroundColor:[NSColor clearColor]];
        [_tradeQtyLabel setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
        [_tradeQtyLabel setDrawsBackground:YES];
        [_tradeQtyLabel setTextAlignment:NSCenterTextAlignment];
        [self.contentView addSubview:_tradeQtyLabel];
    }
    
    if (!self.tradeStrikePriceLabel)
    {
        [self setTradeStrikePriceLabel:[[JNWLabel alloc]initWithFrame:(NSRect){0, CGRectGetMinY(_tradeQtyLabel.frame) - 25, CGRectGetWidth([(NSView*)self.contentView frame]), 25}]];
        [_tradeStrikePriceLabel setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
        [_tradeStrikePriceLabel setBackgroundColor:[NSColor clearColor]];
        [_tradeStrikePriceLabel setDrawsBackground:YES];
        [_tradeStrikePriceLabel setTextAlignment:NSCenterTextAlignment];
        [self.contentView addSubview:_tradeStrikePriceLabel];
    }
    
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

NSUInteger numberOfLeadingCharactersToAffectForCurrency(TTGoxCurrency currency)
{
    switch (currency) {
        case TTGoxCurrencyCHF:
            return 3;
            break;
            
        case TTGoxCurrencyCAD:
            return 1;
            
        case TTGoxCurrencyAUD:
            return 1;
            
        default:
            return 0;
            break;
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

@end
