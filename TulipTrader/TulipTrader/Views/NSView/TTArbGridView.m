//
//  TTArbGridView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/11/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTArbGridView.h"
#import "TTGoxCurrencyController.h"
#import "TTArbitrageStackView.h"
#import "JNWLabel.h"
#import "TTGoxPrivateMessageController.h"
#import "RUConstants.h"
#import "RUClassOrNilUtil.h"

@interface TTArbGridView()

@property(nonatomic, retain)NSMutableArray* arbitrageStackViewsArray;
@property(nonatomic)CGFloat stackWidth;
@property(nonatomic, retain)JNWLabel* arbTableLabel;
@property(nonatomic, retain)JNWLabel* lagLabel;

@end

@implementation TTArbGridView

-(void)lagDidUpdate:(NSNotification*)sender
{
    NSDictionary* lagDict = [[sender userInfo]objectForKey:@"lagDictionary"];
    NSDictionary* lag = [lagDict objectForKey:@"lag"];
    NSString* stamp = kRUStringOrNil([lag objectForKey:@"stamp"]);
    NSString* lagText;
    if (stamp)
    {
        NSDate* lagDate = [NSDate dateWithTimeIntervalSince1970:(stamp.doubleValue / 1000000)];
        lagText = RUStringWithFormat(@"TE Lag: %.1f", (-1 * [lagDate timeIntervalSinceNow]));
    }
    else
        lagText = @"TE Lag: 0";
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.lagLabel setText:lagText];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:TTGoxWebsocketLagUpdateNotificationString];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setArbitrageStackViewsArray:[NSMutableArray array]];
        NSArray* __activeCurrencies = [TTGoxCurrencyController activeCurrencys];
        _stackWidth = floorf(CGRectGetWidth(frame) / __activeCurrencies.count);
        [__activeCurrencies enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
            NSRect targetFrame = (NSRect){0 + (idx * _stackWidth),0,_stackWidth,CGRectGetHeight(frame)};
            TTArbitrageStackView* stackView = [[TTArbitrageStackView alloc]initWithFrame:targetFrame];
            [stackView setBaseCurrency:currencyFromString(obj)];
            [stackView setFrame:targetFrame];
            [self addSubview:stackView];
            [self.arbitrageStackViewsArray addObject:stackView];
        }];
        [self setArbTableLabel:[[JNWLabel alloc]initWithFrame:(NSRect){CGRectGetMidX(frame) - 90, CGRectGetHeight(frame) - 20, 180, 20}]];
        [_arbTableLabel setText:@"Arbitrage Tables"];
        [_arbTableLabel setTextAlignment:NSCenterTextAlignment];
//        [self addSubview:self.arbTableLabel];
        
        [self setLagLabel:[[JNWLabel alloc]initWithFrame:(NSRect){CGRectGetMidX(frame) - 40, CGRectGetHeight(frame) - 40, 100, 20}]];
        [self.lagLabel setTextAlignment:NSLeftTextAlignment];
        [self addSubview:self.lagLabel];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(lagDidUpdate:) name:TTGoxWebsocketLagUpdateNotificationString object:nil];
    }
    return self;
}

//-(void)drawRect:(NSRect)dirtyRect
//{
//    [[NSColor redColor]setFill];
//    NSRectFill(dirtyRect);
//}



@end
