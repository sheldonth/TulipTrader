//
//  TTTradeExecutionBox.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/22/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTTradeExecutionBox.h"
#import "JNWLabel.h"
#import "RUConstants.h"
#import "TTGoxHTTPController.h"

@interface TTTradeExecutionBox()

@property(nonatomic, retain)NSButton* buyActionButton;
@property(nonatomic, retain)NSButton* sellActionButton;

@property(nonatomic, retain)NSButton* marketOrderButton;
@property(nonatomic, retain)NSButton* limitOrderButton;

@property(nonatomic, retain)JNWLabel* orderAmountlabel;
@property(nonatomic, retain)JNWLabel* orderPriceLabel;

@property(nonatomic, retain)NSTextField* orderAmountTextField;
@property(nonatomic, retain)NSTextField* orderPriceTextField;

@property(nonatomic, retain)NSButton* tradeExecutionButton;
@property(nonatomic, retain)NSButton* quoteButton;

@property(nonatomic, retain)TTDepthOrder* insideActionablePosition;

@property(nonatomic, retain)JNWLabel* priceLabel;
@property(nonatomic, retain)JNWLabel* priceValueLabel;

@property(nonatomic, retain)JNWLabel* quantityLabel;
@property(nonatomic, retain)JNWLabel* quantityValueLabel;

@property(nonatomic, retain)JNWLabel* slippageLabel;
@property(nonatomic, retain)JNWLabel* slippageValueLabel;

@property(nonatomic, retain)JNWLabel* slippagePercentageLabel;
@property(nonatomic, retain)JNWLabel* slippagePercentageValueLabel;

@property(nonatomic, retain)JNWLabel* serverQuoteLabel;
@property(nonatomic, retain)JNWLabel* serverQuoteValueLabel;

@end

static CGSize sharedLabelSize;

@implementation TTTradeExecutionBox

static NSFont* accountActionsFont;

+(void)initialize
{
    if (self == [TTTradeExecutionBox class])
    {
        accountActionsFont = [NSFont fontWithName:@"Menlo" size:14.f];
        sharedLabelSize = (CGSize){100, 20};
    }
}

-(void)setInsideActionablePosition:(TTDepthOrder *)insideActionablePosition
{
    [self willChangeValueForKey:@"insideActionablePosition"];
    if (![self.insideActionablePosition isEqual:insideActionablePosition])
    {
        if (self.orderAmountTextField.stringValue.length > 0)
        {
            
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.orderPriceTextField.cell setPlaceholderString:RUStringWithFormat(@"%.5f", insideActionablePosition.price.floatValue)];
                [self.orderAmountTextField.cell setPlaceholderString:RUStringWithFormat(@"%.5f", insideActionablePosition.amount.floatValue)];
                [self.priceValueLabel setText:RUStringWithFormat(@"%.2f", insideActionablePosition.price.floatValue * insideActionablePosition.amount.floatValue)];
                [self.quantityValueLabel setText:RUStringWithFormat(@"%f", insideActionablePosition.amount.floatValue)];
                [self.slippageValueLabel setText:RUStringWithFormat(@"0")];
                [self.slippagePercentageValueLabel setText:RUStringWithFormat(@"0")];
            });
        }
    }
    _insideActionablePosition = insideActionablePosition;
    [self didChangeValueForKey:@"insideActionablePosition"];
}

-(void)setExecutionState:(TTAccountWindowExecutionState)executionState
{
    [self willChangeValueForKey:@"executionState"];
    switch (executionState) {
        case TTAccountWindowExecutionStateBuying:
            [self setInsideActionablePosition:[self.askArray objectAtIndex:0]];
            break;
            
        case TTAccountWindowExecutionStateSelling:
            [self setInsideActionablePosition:[self.bidArray lastObject]];
            break;
            
        case TTAccountWindowExecutionStateNone:
        default:
            break;
    }
    _executionState = executionState;
    [self didChangeValueForKey:@"executionState"];
}

-(void)setExecutionType:(TTAccountWindowExecutionType)executionType
{
    [self willChangeValueForKey:@"executionType"];
    switch (executionType) {
        case TTAccountWindowExecutionTypeLimit:
            [self.orderPriceTextField setEditable:YES];
            [self.orderPriceTextField setSelectable:YES];
            break;
            
        case TTAccountWindowExecutionTypeMarket:
            [self.orderPriceTextField setEditable:NO];
            [self.orderPriceTextField setSelectable:NO];
            break;
            
        case TTAccountWindowExecutionTypeNone:
        default:
            
            break;
    }
    _executionType = executionType;
    [self didChangeValueForKey:@"executionType"];
}

-(void)setBidArray:(NSArray *)bidArray
{
    if (self.executionState == TTAccountWindowExecutionStateSelling)
    {
        [self setInsideActionablePosition:[bidArray lastObject]];
    }
    [self willChangeValueForKey:@"bidArray"];
    _bidArray = bidArray;
    [self didChangeValueForKey:@"bidArray"];
}

-(void)setAskArray:(NSArray *)askArray
{
    if (self.executionState == TTAccountWindowExecutionStateBuying)
    {
        [self setInsideActionablePosition:[askArray objectAtIndex:0]];
    }
    [self willChangeValueForKey:@"askArray"];
    _askArray = askArray;
    [self didChangeValueForKey:@"askArray"];
}

#pragma mark buttons

-(void)marketOrderButtonPressed:(NSButton*)sender
{
    if (_limitOrderButton.state == NSOnState)
        [_limitOrderButton setState:NSOffState];
    [self setExecutionType:TTAccountWindowExecutionTypeMarket];
    [sender setState:NSOnState];
}

-(void)limitOrderButtonPressed:(NSButton*)sender
{
    if (_marketOrderButton.state == NSOnState)
        [_marketOrderButton setState:NSOffState];
    [self setExecutionType:TTAccountWindowExecutionTypeLimit];
    [sender setState:NSOnState];
}

-(void)buyActionButtonPressed:(NSButton*)sender
{
    if (_sellActionButton.state == NSOnState)
        [_sellActionButton setState:NSOffState];
    [self setExecutionState:TTAccountWindowExecutionStateBuying];
    [sender setState:NSOnState];
}

-(void)sellActionButtonPressed:(NSButton*)sender
{
    if (_buyActionButton.state == NSOnState)
        [_buyActionButton setState:NSOffState];
    [self setExecutionState:TTAccountWindowExecutionStateSelling];
    [sender setState:NSOnState];
}

-(void)orderAmountTextFieldCallbackDidFire:(NSTextField*)sender
{
    [self doQuoteWithNumberStringValue:sender.floatValue];
}

-(void)orderPriceTextFieldCallbackDidFire:(id)sender
{
    
}

-(void)controlTextDidChange:(NSNotification *)obj
{
    NSTextField* textFieldSender = [obj object];
    NSNumberFormatter* nf = [[NSNumberFormatter alloc]init];
    NSNumber* numberResult = nil;
    numberResult = [nf numberFromString:textFieldSender.stringValue];
    if (!numberResult)
        [textFieldSender setStringValue:@""];
    else
    {
        switch (textFieldSender.tag) {
            case 1:
                
                break;
                
            case 2:
                
                break;
                
            default:
            {
                NSException* e = [[NSException alloc]initWithName:NSInternalInconsistencyException reason:@"Bad Control Text Tag" userInfo:nil];
                @throw e;
                break;
            }
        }
    }
}

-(void)executeTransation
{
    float amountFloatResult = self.orderAmountTextField.floatValue;
    float priceFloatResult = self.orderPriceTextField.floatValue;
    if (amountFloatResult)
    {
        [_httpController placeOrder:self.executionState amountInteger:(amountFloatResult * 100000000) placementType:self.executionType priceInteger:(priceFloatResult * 100000) withCompletion:^(BOOL success, NSDictionary *callbackData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.orderAmountTextField setStringValue:@""];
                [self.orderPriceTextField setStringValue:@""];
            });
        } withFailBlock:^(NSError *error) {
            
        }];
    }
}

-(void)doQuoteWithNumberStringValue:(float)val
{
    if (val)
    {
        [_httpController getQuoteForExecutionState:self.executionState amount:(val * 100000000) withCompletion:^(NSNumber *cost) {
            [self.serverQuoteValueLabel setText:RUStringWithFormat(@"$%.2f", cost.floatValue / 100000.f)];
        } failBlock:^{
            
        }];
    }
}

-(void)quoteButtonPressed:(NSButton*)sender
{
    [self doQuoteWithNumberStringValue:sender.floatValue];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBuyActionButton:[[NSButton alloc]initWithFrame:NSZeroRect]];
        [_buyActionButton setButtonType:NSPushOnPushOffButton];
        [_buyActionButton setTarget:self];
        [_buyActionButton setAction:@selector(buyActionButtonPressed:)];
        [_buyActionButton setBezelStyle:NSRoundedBezelStyle];
        [_buyActionButton setTitle:@"Buy"];
        [_buyActionButton setState:NSOnState];
        [self.contentView addSubview:_buyActionButton];
        
        [self setSellActionButton:[[NSButton alloc]initWithFrame:NSZeroRect]];
        [_sellActionButton setButtonType:NSPushOnPushOffButton];
        [_sellActionButton setTarget:self];
        [_sellActionButton setAction:@selector(sellActionButtonPressed:)];
        [_sellActionButton setBezelStyle:NSRoundedBezelStyle];
        [_sellActionButton setTitle:@"Sell"];
        [self.contentView addSubview:_sellActionButton];
        
        [self setMarketOrderButton:[[NSButton alloc]initWithFrame:NSZeroRect]];
        [_marketOrderButton setButtonType:NSPushOnPushOffButton];
        [_marketOrderButton setTarget:self];
        [_marketOrderButton setAction:@selector(marketOrderButtonPressed:)];
        [_marketOrderButton setBezelStyle:NSRoundedBezelStyle];
        [_marketOrderButton setTitle:@"Market"];
        [_marketOrderButton setState:NSOnState];
        [self.contentView addSubview:_marketOrderButton];
        
        [self setLimitOrderButton:[[NSButton alloc]initWithFrame:NSZeroRect]];
        [_limitOrderButton setButtonType:NSPushOnPushOffButton];
        [_limitOrderButton setTarget:self];
        [_limitOrderButton setAction:@selector(limitOrderButtonPressed:)];
        [_limitOrderButton setBezelStyle:NSRoundedBezelStyle];
        [_limitOrderButton setTitle:@"Limit"];
        [self.contentView addSubview:_limitOrderButton];
        
        [self setOrderAmountlabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_orderAmountlabel setText:@"Amount:"];
        [_orderAmountlabel setTextAlignment:NSRightTextAlignment];
        [self.contentView addSubview:_orderAmountlabel];
        
        [self setOrderPriceLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [_orderPriceLabel setTextAlignment:NSRightTextAlignment];
        [_orderPriceLabel setText:@"Price:"];
        [self.contentView addSubview:_orderPriceLabel];
        
        [self setOrderAmountTextField:[[NSTextField alloc]initWithFrame:NSZeroRect]];
        [_orderAmountTextField setAlignment:NSCenterTextAlignment];
        [_orderAmountTextField.cell setPlaceholderString:@"0 BTC"];
        [_orderAmountTextField.cell setBezelStyle:NSTextFieldRoundedBezel];
        [_orderAmountTextField setBezeled:YES];
        [_orderAmountTextField setTag:1];
        [_orderAmountTextField setTarget:self];
        [_orderAmountTextField setAction:@selector(orderAmountTextFieldCallbackDidFire:)];
        [_orderAmountTextField setDelegate:self];
        [self.contentView addSubview:_orderAmountTextField];
        
        [self setOrderPriceTextField:[[NSTextField alloc]initWithFrame:NSZeroRect]];
        [_orderPriceTextField setAlignment:NSCenterTextAlignment];
        [_orderPriceTextField.cell setPlaceholderString:@"$0.00"];
        [_orderPriceTextField setBezeled:YES];
        [_orderPriceTextField setTag:2];
        [_orderPriceTextField setDelegate:self];
        [_orderPriceTextField setTarget:self];
        [_orderPriceTextField setAction:@selector(orderPriceTextFieldCallbackDidFire:)];
        [_orderPriceTextField.cell setBezelStyle:NSTextFieldRoundedBezel];
        [self.contentView addSubview:_orderPriceTextField];
        
        [self setTradeExecutionButton:[[NSButton alloc]initWithFrame:NSZeroRect]];
        [_tradeExecutionButton setTitle:@"EXECUTE"];
        [_tradeExecutionButton setBordered:YES];
        [_tradeExecutionButton setTarget:self];
        [_tradeExecutionButton setAction:@selector(executeTransation)];
        [self.contentView addSubview:_tradeExecutionButton];
        
        [self setQuoteButton:[[NSButton alloc]initWithFrame:NSZeroRect]];
        [_quoteButton setTitle:@"QUOTE"];
        [_quoteButton setTarget:self];
        [_quoteButton setAction:@selector(quoteButtonPressed:)];
        [self.contentView addSubview:_quoteButton];
        
        NSMutableArray* labelArrays = [NSMutableArray array];
        
        [self setPriceLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [labelArrays addObject:_priceLabel];
        [self.contentView addSubview:_priceLabel];
        
        [self setPriceValueLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [labelArrays addObject:_priceValueLabel];
        [self.contentView addSubview:_priceValueLabel];
        
        [self setQuantityLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [labelArrays addObject:_quantityLabel];
        [self.contentView addSubview:_quantityLabel];
        
        [self setQuantityValueLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [labelArrays addObject:_quantityValueLabel];
        [self.contentView addSubview:_quantityValueLabel];
        
        [self setSlippageLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [labelArrays addObject:_slippageLabel];
        [self.contentView addSubview:_slippageLabel];
        
        [self setSlippageValueLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [labelArrays addObject:_slippageValueLabel];
        [self.contentView addSubview:_slippageValueLabel];
        
        [self setSlippagePercentageLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [labelArrays addObject:_slippagePercentageLabel];
        [self.contentView addSubview:_slippagePercentageLabel];
        
        [self setSlippagePercentageValueLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [labelArrays addObject:_slippagePercentageValueLabel];
        [self.contentView addSubview:_slippagePercentageValueLabel];
        
        [self setServerQuoteLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [labelArrays addObject:_serverQuoteLabel];
        [self.contentView addSubview:_serverQuoteLabel];
        
        [self setServerQuoteValueLabel:[[JNWLabel alloc]initWithFrame:NSZeroRect]];
        [labelArrays addObject:_serverQuoteValueLabel];
        [self.contentView addSubview:_serverQuoteValueLabel];
        
        [_priceLabel setText:@"Price: "];
        [_quantityLabel setText:@"Quantity: "];
        [_slippageLabel setText:@"Slippage: "];
        [_slippagePercentageLabel setText:@"Slippage %: "];
        [_serverQuoteLabel setText:@"Market Quote:"];
        
        [labelArrays enumerateObjectsUsingBlock:^(JNWLabel* obj, NSUInteger idx, BOOL *stop) {
            if (idx % 2 == 0)
                [obj setTextAlignment:NSRightTextAlignment];
            else
                [obj setTextAlignment:NSCenterTextAlignment];
        }];
        
        [self setExecutionState:TTAccountWindowExecutionStateBuying];
        [self setExecutionType:TTAccountWindowExecutionTypeMarket];
    }
        
    return self;
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [_buyActionButton setFrame:(NSRect){35, CGRectGetHeight(self.frame) - 50, 80, 30}];
    [_sellActionButton setFrame:(NSRect){CGRectGetMaxX(_buyActionButton.frame), CGRectGetHeight(self.frame) - 50, 80, 30}];
    [_marketOrderButton setFrame:(NSRect){CGRectGetMinX(_buyActionButton.frame), CGRectGetHeight(self.frame) - 85, 80, 30}];
    [_limitOrderButton setFrame:(NSRect){CGRectGetMaxX(_marketOrderButton.frame), CGRectGetHeight(self.frame) - 85, 80, 30}];
    [_orderAmountlabel setFrame:(NSRect){0, CGRectGetMinY(_sellActionButton.frame) - 74, 80, 25}];
    [_orderPriceLabel setFrame:(NSRect){0, CGRectGetMinY(_orderAmountlabel.frame) - 30, 80, 25}];
    [_orderAmountTextField setFrame:(NSRect){CGRectGetMaxX(_orderAmountlabel.frame) + 20, CGRectGetMinY(_sellActionButton.frame) - 80, 120, 45}];
    [_orderPriceTextField setFrame:(NSRect){CGRectGetMaxX(_orderPriceLabel.frame) + 20, CGRectGetMinY(_orderPriceLabel.frame) + 3, 120, 25}];
    [_tradeExecutionButton setFrame:(NSRect){127, 5, 117, 26}];
    [_quoteButton setFrame:(NSRect){5, 5, 117, 26}];
    [_priceLabel setFrame:(NSRect){(CGRectGetWidth(self.frame) / 2) + 15, CGRectGetHeight(self.frame) - 40, sharedLabelSize}];
    [_priceValueLabel setFrame:(NSRect){CGRectGetMaxX(_priceLabel.frame), CGRectGetMinY(_priceLabel.frame), sharedLabelSize}];
    [_quantityLabel setFrame:(NSRect){CGRectGetMinX(_priceLabel.frame), CGRectGetMinY(_priceLabel.frame) - 30, sharedLabelSize}];
    [_quantityValueLabel setFrame:(NSRect){CGRectGetMaxX(_quantityLabel.frame), CGRectGetMinY(_priceLabel.frame) - 30, sharedLabelSize}];
    [_slippageLabel setFrame:(NSRect){CGRectGetMinX(_quantityLabel.frame), CGRectGetMinY(_quantityLabel.frame) - 30, sharedLabelSize}];
    [_slippageValueLabel setFrame:(NSRect){CGRectGetMaxX(_slippageLabel.frame), CGRectGetMinY(_slippageLabel.frame), sharedLabelSize}];
    [_slippagePercentageLabel setFrame:(NSRect){CGRectGetMinX(_slippageLabel.frame), CGRectGetMinY(_slippageLabel.frame) - 30, sharedLabelSize}];
    [_slippagePercentageValueLabel setFrame:(NSRect){CGRectGetMaxX(_slippagePercentageLabel.frame), CGRectGetMinY(_slippagePercentageLabel.frame), sharedLabelSize}];
    [_serverQuoteLabel setFrame:(NSRect){CGRectGetMinX(_slippagePercentageLabel.frame), CGRectGetMinY(_slippagePercentageLabel.frame) - 30, sharedLabelSize}];
    [_serverQuoteValueLabel setFrame:(NSRect){CGRectGetMaxX(_serverQuoteLabel.frame), CGRectGetMinY(_serverQuoteLabel.frame), sharedLabelSize}];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

@end
