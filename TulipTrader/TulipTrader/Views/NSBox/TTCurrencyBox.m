//
//  TTCurrencyBox.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/25/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTCurrencyBox.h"
#import "TTTextView.h"

@interface TTCurrencyBox ()

@property (nonatomic, retain) NSImageView* flagImage;
@property (nonatomic, retain) TTTextView* priceText;

@end

@implementation TTCurrencyBox

-(void)setCurrency:(TTGoxCurrency)currency
{
    [self willChangeValueForKey:@"currency"];
    _currency = currency;
    [self didChangeValueForKey:@"currency"];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBorderWidth:2.f];
        [self setBorderColor:[NSColor blackColor]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
