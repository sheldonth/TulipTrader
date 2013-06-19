//
//  TTDepthGridView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/11/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTDepthGridView.h"
#import "TTGoxHTTPController.h"
#import "RUConstants.h"
#import "TTGoxCurrencyController.h"
#import "TTDepthStackView.h"
#import "TTGoxCurrency.h"
#import "TTDepthGridViewColumnView.h"

@implementation TTDepthGridView

-(void)depthNotificationObserved:(NSNotification*)notification
{
    
}

-(void)depthChangeObserved:(NSDictionary *)depthDictionary
{
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:TTGoxWebsocketDepthNotificationString];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        NSArray* __activeCurrencies = [TTGoxCurrencyController activeCurrencys];
        CGFloat columnWidth = floorf(CGRectGetWidth(frame) / __activeCurrencies.count);
        [__activeCurrencies enumerateObjectsUsingBlock:^(NSString* currencyStr, NSUInteger idx, BOOL *stop) {
            TTDepthGridViewColumnView* column = [[TTDepthGridViewColumnView alloc]initWithFrame:(NSRect){columnWidth * idx, 0, columnWidth, CGRectGetHeight(frame)}];
            [column setCurrency:currencyFromString(currencyStr)];
            [self addSubview:column];
        }];
        
        TTGoxPrivateMessageController* privateMessageController = [TTGoxPrivateMessageController sharedInstance];
        [privateMessageController setDepthDelegate:self];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(depthNotificationObserved:) name:TTGoxWebsocketDepthNotificationString object:nil];
    }
    return self;
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//    [[NSColor orangeColor] setFill];
//    NSRectFill(dirtyRect);
//}

@end
