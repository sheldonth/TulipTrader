//
//  TTCurrencyBox.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/25/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTCurrencyBox.h"
#import "TTAppDelegate.h"
#import "RUConstants.h"
#import "NSColor+Hex.h"
#import "JNWLabel.h"
#import "TTCurrency.h"

@interface TTCurrencyBox ()
@property (nonatomic, retain) NSImageView* flagImage;
@property (nonatomic, retain) JNWLabel* orderBookTitleLabel;
@property (nonatomic, retain) JNWLabel* lastLabel;
@property (nonatomic, retain) JNWLabel* lastValueLabel;
@property (nonatomic, retain) JNWLabel* buyLabel;
@property (nonatomic, retain) JNWLabel* buyValueLabel;
@property (nonatomic, retain) JNWLabel* sellLabel;
@property (nonatomic, retain) JNWLabel* sellValueLabel;
@property (nonatomic, retain) JNWLabel* highLabel;
@property (nonatomic, retain) JNWLabel* highValueLabel;
@property (nonatomic, retain) JNWLabel* lowLabel;
@property (nonatomic, retain) JNWLabel* lowValueLabel;
@property (nonatomic, retain) JNWLabel* volumeLabel;
@property (nonatomic, retain) JNWLabel* volumeValueLabel;
@property (nonatomic, retain) JNWLabel* vwapLabel;
@property (nonatomic, retain) JNWLabel* vwapValueLabel;
@property (nonatomic, retain) JNWLabel* averageLabel;
@property (nonatomic, retain) JNWLabel* averageValueLabel;

@property (nonatomic, retain) JNWLabel* requestCountLabel;
@property (nonatomic, retain) JNWLabel* fullDepthLabel;
@property (nonatomic, retain) JNWLabel* partialDepthLabel;

@property (nonatomic, retain) NSTimer* refreshTimer;

NSUInteger numberOfLeadingCharactersToAffectForCurrency(TTCurrency currency);

@end

@implementation TTCurrencyBox

static NSFont* titleFont;
static NSFont* valueLabelFont;
static NSFont* valueFont;
static NSNumberFormatter* spreadNumberFormatter;

#define valueLabelHeight 20.f
#define valueHeight 50.f

+(void)initialize
{
    titleFont = [NSFont fontWithName:@"Menlo" size:32.f];
    valueLabelFont = [NSFont fontWithName:@"Menlo" size:12.f];
    valueFont = [NSFont fontWithName:@"Menlo" size:16.f];
    spreadNumberFormatter = [NSNumberFormatter new];
    [spreadNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [spreadNumberFormatter setMaximumFractionDigits:0];
}

NSString* stringForTick(TTTick* tick)
{
    return RUStringWithFormat(@"%@", tick.display_short);
}

-(void)setLastTicker:(TTTicker *)lastTicker
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.lastValueLabel setText:stringForTick(lastTicker.last)];
        [self.buyValueLabel setText:stringForTick(lastTicker.buy)];
        [self.sellValueLabel setText:stringForTick(lastTicker.sell)];
        [self.highValueLabel setText:stringForTick(lastTicker.high)];
        [self.lowValueLabel setText:stringForTick(lastTicker.low)];
        [self.volumeValueLabel setText:stringForTick(lastTicker.vol)];
        [self.vwapValueLabel setText:stringForTick(lastTicker.vwap)];
        [self.averageValueLabel setText:stringForTick(lastTicker.average)];
    });
}

-(void)setOrderBookPtr:(TTOrderBook *)orderBookPtr
{
    [self willChangeValueForKey:@"orderBookPtr"];
    _orderBookPtr = orderBookPtr;
    [self didChangeValueForKey:@"orderBookPtr"];
    NSSize s = [self.orderBookPtr.title sizeWithAttributes:@{NSFontAttributeName : titleFont}];
    CGFloat offset = ([(NSView*)self.contentView frame].size.height - s.height) / 2;
    [self.orderBookTitleLabel setFrame:(NSRect){0, offset, s}];
    [self.orderBookTitleLabel setText:self.orderBookPtr.title];
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    NSRect contentViewFrame = [(NSView*)self.contentView frame];
    CGFloat tickerElementWidth = floorf(CGRectGetWidth(contentViewFrame) / 10);
    [_orderBookTitleLabel setFrame:(NSRect){0, 0, tickerElementWidth * 2, CGRectGetHeight(contentViewFrame) - 10}];
    [_lastLabel setFrame:(NSRect){CGRectGetMaxX(self.orderBookTitleLabel.frame), CGRectGetHeight(contentViewFrame) - valueLabelHeight, tickerElementWidth, valueLabelHeight}];
    [_lastValueLabel setFrame:(NSRect){CGRectGetMaxX(self.orderBookTitleLabel.frame), 0, tickerElementWidth, valueHeight}];
    [_buyLabel setFrame:(NSRect){CGRectGetMaxX(_lastLabel.frame), CGRectGetHeight(contentViewFrame) - valueLabelHeight, tickerElementWidth, valueLabelHeight}];
    [_buyValueLabel setFrame:(NSRect){CGRectGetMaxX(_lastLabel.frame), 0, tickerElementWidth, valueHeight}];
    [_sellLabel setFrame:(NSRect){CGRectGetMaxX(_buyLabel.frame), CGRectGetHeight(contentViewFrame) - valueLabelHeight, tickerElementWidth, valueLabelHeight}];
    [_sellValueLabel setFrame:(NSRect){CGRectGetMaxX(_buyLabel.frame), 0, tickerElementWidth, valueHeight}];
    [_highLabel setFrame:(NSRect){CGRectGetMaxX(_sellLabel.frame), CGRectGetHeight(contentViewFrame) - valueLabelHeight, tickerElementWidth, valueLabelHeight}];
    [_highValueLabel setFrame:(NSRect){CGRectGetMaxX(_sellLabel.frame), 0, tickerElementWidth, valueHeight}];
    [_lowLabel setFrame:(NSRect){CGRectGetMaxX(_highLabel.frame), CGRectGetHeight(contentViewFrame) - valueLabelHeight, tickerElementWidth, valueLabelHeight}];
    [_lowValueLabel setFrame:(NSRect){CGRectGetMaxX(_highLabel.frame), 0, tickerElementWidth, valueHeight}];
    [_volumeLabel setFrame:(NSRect){CGRectGetMaxX(_lowLabel.frame), CGRectGetHeight(contentViewFrame) - valueLabelHeight, tickerElementWidth, valueLabelHeight}];
    [_volumeValueLabel setFrame:(NSRect){CGRectGetMaxX(_lowLabel.frame), 0, tickerElementWidth, valueHeight}];
    [_vwapLabel setFrame:(NSRect){CGRectGetMaxX(_volumeLabel.frame), CGRectGetHeight(contentViewFrame) - valueLabelHeight, tickerElementWidth, valueLabelHeight}];
    [_vwapValueLabel setFrame:(NSRect){CGRectGetMaxX(_volumeLabel.frame), 0, tickerElementWidth, valueHeight}];
    [_averageLabel setFrame:(NSRect){CGRectGetMaxX(_vwapLabel.frame), CGRectGetHeight(contentViewFrame) - valueLabelHeight, tickerElementWidth, valueLabelHeight}];
    [_averageValueLabel setFrame:(NSRect){CGRectGetMaxX(_vwapLabel.frame), 0, tickerElementWidth, valueHeight}];
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
        [self setTitlePosition:NSNoTitle];
        
        NSRect contentViewFrame = [(NSView*)self.contentView frame];
        NSString* defaultValueLabel = RUStringWithFormat(@"---.-----");
        
        [self setOrderBookTitleLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [self.orderBookTitleLabel setFont:titleFont];
        [self.orderBookTitleLabel setTextAlignment:NSCenterTextAlignment];
        [self.contentView addSubview:self.orderBookTitleLabel];
        
        [self setLastLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_lastLabel setFont:valueLabelFont];
        [_lastLabel setTextAlignment:NSCenterTextAlignment];
        [_lastLabel setText:@"LAST"];
        [self.contentView addSubview:self.lastLabel];
        
        [self setLastValueLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_lastValueLabel setFont:valueFont];
        [_lastValueLabel setText:defaultValueLabel];
        [_lastValueLabel setTextAlignment:NSCenterTextAlignment];
        [self.contentView addSubview:self.lastValueLabel];
        
        [self setBuyLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_buyLabel setFont:valueLabelFont];
        [_buyLabel setTextAlignment:NSCenterTextAlignment];
        [_buyLabel setText:@"BUY"];
        [self.contentView addSubview:_buyLabel];
        
        [self setBuyValueLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_buyValueLabel setFont:valueFont];
        [_buyValueLabel setTextAlignment:NSCenterTextAlignment];
        [_buyValueLabel setText:defaultValueLabel];
        [self.contentView addSubview:_buyValueLabel];
        
        [self setSellLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_sellLabel setFont:valueLabelFont];
        [_sellLabel setTextAlignment:NSCenterTextAlignment];
        [_sellLabel setText:@"SELL"];
        [self.contentView addSubview:_sellLabel];
        
        [self setSellValueLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_sellValueLabel setTextAlignment:NSCenterTextAlignment];
        [_sellValueLabel setFont:valueFont];
        [_sellValueLabel setText:defaultValueLabel];
        [self.contentView addSubview:_sellValueLabel];
        
        [self setHighLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_highLabel setTextAlignment:NSCenterTextAlignment];
        [_highLabel setFont:valueLabelFont];
        [_highLabel setText:@"HIGH"];
        [self.contentView addSubview:_highLabel];
        
        [self setHighValueLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_highValueLabel setTextAlignment:NSCenterTextAlignment];
        [_highValueLabel setFont:valueFont];
        [_highValueLabel setText:defaultValueLabel];
        [self.contentView addSubview:_highValueLabel];
        
        [self setLowLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_lowLabel setTextAlignment:NSCenterTextAlignment];
        [_lowLabel setFont:valueLabelFont];
        [_lowLabel setText:@"LOW"];
        [self.contentView addSubview:_lowLabel];

        [self setLowValueLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_lowValueLabel setTextAlignment:NSCenterTextAlignment];
        [_lowValueLabel setFont:valueFont];
        [_lowValueLabel setText:defaultValueLabel];
        [self.contentView addSubview:_lowValueLabel];
        
        [self setVolumeLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_volumeLabel setTextAlignment:NSCenterTextAlignment];
        [_volumeLabel setFont:valueLabelFont];
        [_volumeLabel setText:@"VOLUME"];
        [self.contentView addSubview:_volumeLabel];
        
        [self setVolumeValueLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_volumeValueLabel setTextAlignment:NSCenterTextAlignment];
        [_volumeValueLabel setFont:valueFont];
        [_volumeValueLabel setText:defaultValueLabel];
        [self.contentView addSubview:_volumeValueLabel];
        
        [self setVwapLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_vwapLabel setTextAlignment:NSCenterTextAlignment];
        [_vwapLabel setFont:valueLabelFont];
        [_vwapLabel setText:@"VWAP"];
        [self.contentView addSubview:_vwapLabel];
        
        [self setVwapValueLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_vwapValueLabel setTextAlignment:NSCenterTextAlignment];
        [_vwapValueLabel setFont:valueFont];
        [_vwapValueLabel setText:defaultValueLabel];
        [self.contentView addSubview:_vwapValueLabel];
        
        [self setAverageLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_averageLabel setTextAlignment:NSCenterTextAlignment];
        [_averageLabel setFont:valueLabelFont];
        [_averageLabel setText:@"AVERAGE"];
        [self.contentView addSubview:_averageLabel];
        
        [self setAverageValueLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_averageValueLabel setTextAlignment:NSCenterTextAlignment];
        [_averageValueLabel setFont:valueFont];
        [_averageValueLabel setText:defaultValueLabel];
        [self.contentView addSubview:_averageValueLabel];
    }
    return self;
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

NSUInteger numberOfLeadingCharactersToAffectForCurrency(TTCurrency currency)
{
    switch (currency) {
        case TTCurrencyCHF:
            return 3;
            break;
            
        case TTCurrencyCAD:
            return 1;
            
        case TTCurrencyAUD:
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
