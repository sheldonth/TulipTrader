//
//  TTTextPaneScrollView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/4/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTTextPaneScrollView.h"

@interface TTTextPaneScrollView ()

@end

@implementation TTTextPaneScrollView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBorderType:NSNoBorder];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setDrawsBackground:NO];
        [self setHasVerticalScroller:YES];
        [self setHasHorizontalScroller:NO];
        [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        _textView = [[TTTextView alloc]initWithFrame:frame];
        [self.textView setDrawsBackground:NO];
        [self.textView setFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]];
        [self.textView setEditable:NO];
        [self.textView setSelectable:NO];
        [self.textView setVerticallyResizable:YES];
        [self.textView setHorizontallyResizable:NO];
        [self.textView setAutoresizingMask:NSViewWidthSizable];
        [[self.textView textContainer] setWidthTracksTextView:YES];
        
        NSSize s = [self contentSize];
        [self.textView setFrame:(NSRect){0,0,s.width, s.height}];
        [self.textView setMinSize:(NSSize){0.f, s.height}];
        [self.textView setMaxSize:(NSSize){FLT_MAX, FLT_MAX}];
        [self.textView.textContainer setContainerSize:(NSSize){s.width, FLT_MAX}];
        
        [self setDocumentView:self.textView];
    }
    
    return self;
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//    // Drawing code here.
//}

@end
