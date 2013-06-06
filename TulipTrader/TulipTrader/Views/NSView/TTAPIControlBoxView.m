//
//  TTAPIControlBoxView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/6/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTAPIControlBoxView.h"
#import "TTTextView.h"
#import "NSView+Utility.h"
#import "NSColor+Hex.h"
#import "RUConstants.h"
#import "TTTextField.h"
#import "TTGoxCurrency.h"
#import "TTGoxHTTPController.h"

@interface TTAPIControlBoxView ()

@property(nonatomic, retain)NSScrollView* scrollView;
@property(nonatomic, retain)TTTextView* dialogTextView;
@property(nonatomic, retain)TTTextField* commandEntryTextField;

@end

@implementation TTAPIControlBoxView

RU_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(TTAPIControlBoxView, sharedInstance);

#define TTAPIControlBoxLeadinString @"> "
#define TTAPIControlBoxTailString @""
#define kTTAPIControlBoxCommandEntryPrompt @"Enter Commands Here"

#pragma mark - static methods

NSArray* kTTAPIActionCommandList;
NSArray* kTTAPIActionObjectList;
NSArray* kTTAPIActionFlagList;

static NSDateFormatter* dateFormatter;
static NSColor* textBackgroundColor;

+(void)initialize
{
    if (self == [TTAPIControlBoxView class])
    {
        textBackgroundColor = [NSColor blackColor];
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        
        kTTAPIActionCommandList = @[@"help", @"set", @"load", @"account", @"clear"];
        kTTAPIActionObjectList = @[@"noisyquotes"];
        kTTAPIActionFlagList = @[@"On", @"Off"];
    }
}

-(void)handleTab
{
    RUDLog(@"HANDLE TAB");
}

-(BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    if (commandSelector == NSSelectorFromString(@"insertTab:"))
    {
        [self handleTab];
        return YES;
    }
    else
        return NO;
}

-(void)mouseDownDidOccurWithEvent:(NSEvent*)theEvent
{
    if ([self.commandEntryTextField.stringValue isEqualToString:kTTAPIControlBoxCommandEntryPrompt])
        [self.commandEntryTextField setStringValue:@""];
}

-(void)parseCommand:(NSString*)commandText
{
    NSArray* components = [commandText componentsSeparatedByString:@" "];
    NSInteger indexPassingTest = [kTTAPIActionCommandList indexOfObjectPassingTest:^BOOL(NSString* obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:[components objectAtIndex:0]])
        {
            *stop = YES;
            return YES;
        }
        else
            return NO;
    }];
    if (indexPassingTest == NSNotFound)
        [TTAPIControlBoxView publishCommand:@"Unrecognized Command"];
    switch (indexPassingTest) {
        case 0:
        {
            NSMutableString* cmds = [NSMutableString stringWithFormat:@"Available Commands Are"];
            [kTTAPIActionCommandList enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
                [cmds appendFormat:@", %@", obj];
            }];
            [TTAPIControlBoxView publishCommand:cmds];
            break;
        }
        case 1:
            [TTAPIControlBoxView publishCommand:@"Set is not yet implemented."];
            break;
            
        case 2:
        {
            TTGoxCurrency currency = currencyFromString([components objectAtIndex:1]);
            if (currency == TTGoxCurrencyNone)
                [TTAPIControlBoxView publishCommand:@"Unknown Currency, Please Try Again"];
            else if (currency == TTGoxCurrencyBTC)
                [TTAPIControlBoxView publishCommand:@"Must specify Bitcoin counter currency, i.e. USD"];
            else
            {
                [TTAPIControlBoxView publishCommand:RUStringWithFormat(@"Assuming Market is MtGox, Loading %@", stringFromCurrency(currency))];
                [[TTGoxHTTPController sharedInstance]updateLatestTradesForCurrency:currency];
            }
            break;
        }
        case 3:
            [[TTGoxHTTPController sharedInstance]loadAccountDataWithCompletion:^(NSDictionary *accountInformation) {
                
            } andFailBlock:^(NSError *e) {
                
            }];
            
        case 4:
            [self.dialogTextView setString:@""];
            
        default:
            break;
    }
    [self.commandEntryTextField setStringValue:@""];
}

-(void)enterCommand:(TTTextField*)sender
{
    [self parseCommand:sender.stringValue];
}

#define kTTAPIControlBoxAllowableScrollOffset 100.f

+(NSString *)currentControlString
{
    TTAPIControlBoxView* pointer = [TTAPIControlBoxView sharedInstance];
    return pointer.dialogTextView.string;
}

+(void)publishCommand:(NSString *)commandText repeating:(BOOL)repeats
{
    TTAPIControlBoxView* pointer = [TTAPIControlBoxView sharedInstance];
    NSString* curStr = [pointer.dialogTextView string];
    if (curStr.length > commandText.length)
    {
        if ([[curStr substringWithRange:NSMakeRange(curStr.length - commandText.length, commandText.length)] isEqualToString:commandText])
        {
            if (!repeats)
                return;
        }
    }
    
    NSMutableString* mutableCopy = [pointer.dialogTextView.string mutableCopy];
    [mutableCopy appendString:RUStringWithFormat(@"\n%@ %@%@%@",[dateFormatter stringFromDate:[NSDate date]], TTAPIControlBoxLeadinString, commandText, TTAPIControlBoxTailString)];
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [pointer.dialogTextView setString:mutableCopy];
            [pointer.scrollView.contentView scrollToPoint:NSMakePoint(0, ((NSView*)pointer.scrollView.documentView).frame.size.height - pointer.scrollView.contentSize.height)];
        });
    }
    else
    {
        [pointer.dialogTextView setString:mutableCopy];
        if (pointer.scrollView.contentView.documentVisibleRect.origin.y)
            [pointer.scrollView.contentView scrollToPoint:NSMakePoint(0, ((NSView*)pointer.scrollView.documentView).frame.size.height - pointer.scrollView.contentSize.height)];
    }
    
}

+(void)publishCommand:(NSString*)commandText
{
    [TTAPIControlBoxView publishCommand:commandText repeating:YES]; //Commands can be repeated by default
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setScrollView:[[NSScrollView alloc]initWithFrame:CGRectZero]];
        [_scrollView setBorderType:NSNoBorder];
        [_scrollView setBackgroundColor:[NSColor clearColor]];
        [_scrollView setDrawsBackground:NO];
        [_scrollView setHasVerticalScroller:YES];
        [_scrollView setHasHorizontalScroller:NO];
        [_scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self addSubview:_scrollView];
        
        [self setDialogTextView:[[TTTextView alloc]initWithFrame:CGRectZero]];
        [_dialogTextView setFont:[NSFont fontWithName:@"Gill Sans" size:14.f]];
        [_dialogTextView setTextColor:[NSColor blackColor]];
        [_dialogTextView setBackgroundColor:[NSColor clearColor]];
        [_dialogTextView setVerticallyResizable:YES];
        [_dialogTextView setHorizontallyResizable:NO];
        [_dialogTextView setAutoresizingMask:NSViewWidthSizable];
        [_dialogTextView setEditable:NO];
        [_dialogTextView setDrawsBackground:NO];
        [[_dialogTextView textContainer] setWidthTracksTextView:YES];
        [_scrollView setDocumentView:_dialogTextView];
        
        [self setCommandEntryTextField:[[TTTextField alloc]initWithFrame:CGRectZero]];
        [_commandEntryTextField setFont:[NSFont fontWithName:@"Gill Sans" size:14.f]];
        [_commandEntryTextField setTextColor:[NSColor blackColor]];
        [_commandEntryTextField setBackgroundColor:[NSColor whiteColor]];
        [_commandEntryTextField setTarget:self];
        [_commandEntryTextField setEditable:YES];
        [_commandEntryTextField setSelectable:YES];
        [_commandEntryTextField setBezeled:YES];
        [_commandEntryTextField setBezelStyle:NSTextFieldSquareBezel];
        [_commandEntryTextField setDelegate:self];
        [_commandEntryTextField setAction:@selector(enterCommand:)];
        [_commandEntryTextField setStringValue:kTTAPIControlBoxCommandEntryPrompt];
        [self addSubview:_commandEntryTextField];
        
        [self setBorderWidth:2.f];
        [self setBorderColor:[NSColor blackColor]];
        [self setTitle:@"Console"];
    }
    return self;
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [_scrollView setFrame:(NSRect){0, 40, CGRectGetWidth(frameRect) - 16, frameRect.size.height - 55}];
    [_commandEntryTextField setFrame:(NSRect){0 ,0, CGRectGetWidth(frameRect) - 15, 30}];
    NSSize s = [_scrollView contentSize];
    [_dialogTextView setFrame:(NSRect){0,0,s.width, s.height}];
    [_dialogTextView setMinSize:(NSSize){0.f, s.height}];
    [_dialogTextView setMaxSize:(NSSize){FLT_MAX, FLT_MAX}];
    [_dialogTextView.textContainer setContainerSize:(NSSize){s.width, FLT_MAX}];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

@end
