//
//  TTFeeBox.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/22/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTFeeBox.h"
#import "JNWLabel.h"
#import "RUConstants.h"
#import "TTTick.h"
#import "TTGoxTransaction.h"

@interface TTFeeBox ()

@property(nonatomic, retain)NSNumber* accountFee;

@property(nonatomic, retain)JNWLabel* feesHistoricLabel;
@property(nonatomic, retain)JNWLabel* feePercentageLabel;

@property(nonatomic, retain)JNWLabel* feePerCoinLabel;

@property(nonatomic, retain)TTTick* monthlyVolume;

@end

@implementation TTFeeBox

static NSFont* labelFont;

static CGFloat labelHeight;

+(void)initialize
{
    if (self == [TTFeeBox class])
    {
        labelFont = [NSFont fontWithName:@"Menlo" size:14.f];
        labelHeight = 20.f;
    }
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFeePercentageLabel:[[JNWLabel alloc]initWithFrame:(NSRect){0, [self.contentView frame].size.height / 2 + 5, CGRectGetWidth([self.contentView frame]) / 2, labelHeight}]];
        [_feePercentageLabel setDrawsBackground:NO];
        [_feePercentageLabel setFont:labelFont];
        [_feePercentageLabel setTextAlignment:NSCenterTextAlignment];
        [self.contentView addSubview:_feePercentageLabel];
        
        [self setFeesHistoricLabel:[[JNWLabel alloc]initWithFrame:(NSRect){0, 0, CGRectGetWidth([self.contentView frame]) / 2, labelHeight}]];
        [_feesHistoricLabel setDrawsBackground:NO];
        [_feesHistoricLabel setFont:labelFont];
        [_feesHistoricLabel setTextAlignment:NSCenterTextAlignment];
        [self.contentView addSubview:_feesHistoricLabel];
        
        [self setFeePerCoinLabel:[[JNWLabel alloc]initWithFrame:(NSRect){CGRectGetWidth([self.contentView frame]) / 2, [self.contentView frame].size.height / 2 + 5, CGRectGetWidth([self.contentView frame]) / 2, labelHeight}]];
        [_feePerCoinLabel setDrawsBackground:NO];
        [_feePerCoinLabel setTextAlignment:NSCenterTextAlignment];
        [_feePerCoinLabel setFont:labelFont];
        [self.contentView addSubview:_feePerCoinLabel];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

-(void)setAccountInformationToDictionary:(NSDictionary*)dic
{
    [self setMonthlyVolume:[TTTick newTickfromDictionary:[dic objectForKey:@"Monthly_Volume"]]];
    [self setAccountFee:[dic objectForKey:@"Trade_Fee"]];
    [self.feePercentageLabel setText:RUStringWithFormat(@"Trade Fee %%: %@", self.accountFee.stringValue)];
}

-(void)setWalletForFeeDetermination:(TTGoxWallet*)wallet
{
    __block double dayFees = 0.f;
    __block double monthFees = 0.f;
    __block double allFees = 0.f;
    [wallet.transactions enumerateObjectsUsingBlock:^(TTGoxTransaction* obj, NSUInteger idx, BOOL *stop) {
        if ([[obj type]isEqualToString:@"fee"])
        {
            if (fabs([[obj date]timeIntervalSinceNow]) < 86400.f)
            {
                dayFees = dayFees + [obj.value.value floatValue];
                monthFees = monthFees + [obj.value.value floatValue];
                allFees = allFees + [obj.value.value floatValue];
            }
            else if (fabs([[obj date]timeIntervalSinceNow]) < 2592000.f)
            {
                monthFees = monthFees + [obj.value.value floatValue];
                allFees = allFees + [obj.value.value floatValue];
            }

            else
            {
                allFees = allFees + [obj.value.value floatValue];
            }
        }
    }];
    
    [_feesHistoricLabel setText:RUStringWithFormat(@"24hr:%@%.3f  30d:%@%.3f", currencySymbolStringFromCurrency(wallet.currency), dayFees, currencySymbolStringFromCurrency(wallet.currency), monthFees)];
}

-(void)setLastTicker:(TTTicker *)lastTicker
{
    [self.feePerCoinLabel setText:RUStringWithFormat(@"Fee/Coin: %@%.2f", currencySymbolStringFromCurrency(currencyFromNumber(lastTicker.last.currency)),(lastTicker.last.value.floatValue * (self.accountFee.floatValue / 100.f)))];
}

@end
