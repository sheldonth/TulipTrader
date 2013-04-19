//
//  TTStatusBarView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/5/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTStatusBarView.h"
#import "TTFrameConstants.h"
#import "RUConstants.h"
#import "TTGoxSocketController.h"

@interface TTStatusBarView ()

@property(nonatomic, retain)NSTextView* connectionStateTextView;
@property(nonatomic, retain)NSTextStorage* connectionStateTextStorage;

@end

@implementation TTStatusBarView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _connectionStateTextStorage = [[NSTextStorage alloc]initWithString:@"Sheldon William Thomas"];
        
        NSLayoutManager* layoutManager = [[NSLayoutManager alloc]init];
        
        [_connectionStateTextStorage addLayoutManager:layoutManager];
        
        NSTextContainer* textContainer = [[NSTextContainer alloc]initWithContainerSize:(NSSize){85, 45}];
        
        [layoutManager addTextContainer:textContainer];
    
        _connectionStateTextView = [[NSTextView alloc]initWithFrame:(NSRect){5, 5, 85, 45} textContainer:textContainer];
        
        [self addSubview:_connectionStateTextView];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
}

-(void)layout
{
    [super layout];
    RUDLog(@"Layout Status bar frame: %@", NSStringFromRect(self.frame));
    [_connectionStateTextView setFrame:(NSRect){5, 5, 85, 40}];
}

// If you invoke display manually, it invokes layout and layout invokes updateConstraints.

@end
