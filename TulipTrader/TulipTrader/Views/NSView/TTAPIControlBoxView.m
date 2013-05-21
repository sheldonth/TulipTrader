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


@interface TTAPIControlBoxView ()

@property(nonatomic, retain)NSScrollView* scrollView;
@property(nonatomic, retain)TTTextView* dialogTextView;
@property(nonatomic, retain)TTTextView* commandEntryPane;

@end

@implementation TTAPIControlBoxView

RU_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(TTAPIControlBoxView, sharedInstance);

static NSColor* textBackgroundColor;

#define TTAPIControlBoxLeadinString @">> "
#define TTAPIControlBoxTailString @""

#pragma mark - static methods

static NSDateFormatter* dateFormatter;

+(void)publishCommand:(NSString*)commandText
{
    TTAPIControlBoxView* pointer = [TTAPIControlBoxView sharedInstance];
    NSMutableString* mutableCopy = [pointer.dialogTextView.string mutableCopy];
    [mutableCopy appendString:RUStringWithFormat(@"\n%@ %@%@%@",[dateFormatter stringFromDate:[NSDate date]], TTAPIControlBoxLeadinString, commandText, TTAPIControlBoxTailString)];
    if (![NSThread mainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [pointer.dialogTextView setString:mutableCopy];
            [pointer.scrollView.contentView scrollToPoint:NSMakePoint(0, ((NSView*)pointer.scrollView.documentView).frame.size.height - pointer.scrollView.contentSize.height)];
        });
    }
    else
    {
        [pointer.dialogTextView setString:mutableCopy];
        [pointer.scrollView.contentView scrollToPoint:NSMakePoint(0, ((NSView*)pointer.scrollView.documentView).frame.size.height - pointer.scrollView.contentSize.height)];
    }
}

+(void)initialize
{
    if (self == [TTAPIControlBoxView class])
    {
        textBackgroundColor = [NSColor blackColor];
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"HH:mm:ss.SS"];
    }
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setScrollView:[[NSScrollView alloc]initWithFrame:CGRectZero]];
        [_scrollView setBorderType:NSNoBorder];
        [_scrollView setHasVerticalScroller:YES];
        [_scrollView setHasHorizontalScroller:NO];
        [_scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self addSubview:_scrollView];
        
        [self setDialogTextView:[[TTTextView alloc]initWithFrame:CGRectZero]];
        [_dialogTextView setFont:[NSFont fontWithName:@"Gill Sans" size:14.f]];
        [_dialogTextView setTextColor:[NSColor whiteColor]];
        [_dialogTextView setBackgroundColor:[NSColor darkGrayColor]];
        [_dialogTextView setVerticallyResizable:YES];
        [_dialogTextView setHorizontallyResizable:NO];
        [_dialogTextView setAutoresizingMask:NSViewWidthSizable];
        [_dialogTextView setEditable:NO];
        [[_dialogTextView textContainer] setWidthTracksTextView:YES];
        [_scrollView setDocumentView:_dialogTextView];
        
        [self setCommandEntryPane:[[TTTextView alloc]initWithFrame:CGRectZero]];
        [_commandEntryPane setFont:[NSFont fontWithName:@"Gill Sans" size:14.f]];
        [_commandEntryPane setTextColor:[NSColor blackColor]];
        [_commandEntryPane setBackgroundColor:[NSColor whiteColor]];
        
    }
    return self;
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [_scrollView setFrame:(NSRect){0, 30,CGRectGetWidth(frameRect),frameRect.size.height - 30}];
    NSSize s = [_scrollView contentSize];
    [_dialogTextView setFrame:(NSRect){0,0,s.width, s.height}];
    [_dialogTextView setMinSize:(NSSize){0.f, s.height}];
    [_dialogTextView setMaxSize:(NSSize){FLT_MAX, FLT_MAX}];
    [_dialogTextView.textContainer setContainerSize:(NSSize){s.width, FLT_MAX}];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [textBackgroundColor setFill];
    NSRectFill(dirtyRect);
}

@end
