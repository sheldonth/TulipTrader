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
{
    @private
    NSArray* buyTicks;
    NSArray* sellTicks;
}
@property (nonatomic, retain) NSImageView* flagImage;
@property (nonatomic, retain) TTTextView* sellPriceText;
@property (nonatomic, retain) TTTextView* buyPriceText;
@property (nonatomic, retain) NSFetchRequest* buyFetchRequest;
@property (nonatomic, retain) NSFetchRequest* sellFetchRequest;
@property (nonatomic, retain) NSTimer* refreshTimer;

@property (assign) NSManagedObjectContext* appDelegateContext;

@end

@implementation TTCurrencyBox

static NSFont* titleFont;
static NSFont* buyFont;
static NSFont* sellFont;

+(void)initialize
{
    titleFont = [NSFont fontWithName:@"American Typewriter" size:10.f];
    buyFont = [NSFont fontWithName:@"Helvetica-Bold" size:14.f];
    sellFont = [NSFont fontWithName:@"Helvetica-Bold" size:14.f];
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

-(void)reloadBuy:(NSNotification*)sender
{
    TTGoxCurrency notifCurrency = currencyFromNumber([sender.userInfo objectForKey:@"currency"]);
    if (notifCurrency == self.currency)
        [self runBuy];
}

-(void)reloadSell:(NSNotification*)sender
{
    TTGoxCurrency notifCurrency = currencyFromNumber([sender.userInfo objectForKey:@"currency"]);
    if (notifCurrency == self.currency)
        [self runSell];
}

-(void)runSell
{
    NSError* e = nil;
    sellTicks = [_appDelegateContext executeFetchRequest:_sellFetchRequest error:&e];
    if (e)
        @throw e;
    if (sellTicks.count)
    {
        NSNumber* lastSell = [[(Ticker*)[sellTicks objectAtIndex:0]sell] value];
        [_sellPriceText setString:RUStringWithFormat(@"%@", stringShortenedForCurrencyBox(lastSell.stringValue))];
    }
    else
        [_sellPriceText setString:RUStringWithFormat(@"--:-----")];
}

-(void)runBuy
{
    NSError* e = nil;
    buyTicks = [_appDelegateContext executeFetchRequest:_buyFetchRequest error:&e];
    if (e)
        @throw e;
    if (buyTicks.count)
    {
        NSNumber* lastBuy = [[(Ticker*)[buyTicks objectAtIndex:0]buy] value];
        [_buyPriceText setString:RUStringWithFormat(@"%@", stringShortenedForCurrencyBox(lastBuy.stringValue))];
    }
    else
        [_buyPriceText setString:@"--.-----"];
}

-(void)runQueries
{
    [self runBuy];
    [self runSell];
}

-(void)setCurrency:(TTGoxCurrency)currency
{
    [self willChangeValueForKey:@"currency"];
    _currency = currency;
    [self setTitle:stringFromCurrency(currency)];
    [self.sellFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"sell.currency == %@", numberFromCurrency(currency)]];
    [self.buyFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"buy.currency == %@", numberFromCurrency(currency)]];
    [self didChangeValueForKey:@"currency"];
    [self runQueries];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TTBuyNotificationString object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TTSellNotificationString object:nil];
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
        [self setBuyFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Ticker"]];
        [self setSellFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Ticker"]];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO];
        [_buyFetchRequest setSortDescriptors:@[sortDescriptor]];
        [_sellFetchRequest setSortDescriptors:@[sortDescriptor]];
        [_buyFetchRequest setFetchLimit:1];
        [_sellFetchRequest setFetchLimit:1];
        
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
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadBuy:) name:TTBuyNotificationString object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadSell:) name:TTSellNotificationString object:nil];
    }
    return self;
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [_buyPriceText setFrame:(NSRect){5, CGRectGetHeight(frameRect) - 60, 90, 30}];
    [_sellPriceText setFrame:(NSRect){5, CGRectGetHeight(frameRect) - 80, 90, 30}];
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

//- (void)drawRect:(NSRect)dirtyRect
//{
//    [[NSColor blueColor]setFill];
//    NSRectFill(dirtyRect);
//}

@end
