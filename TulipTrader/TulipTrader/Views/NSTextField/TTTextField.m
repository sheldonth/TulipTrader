//
//  TTTextField.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/21/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTTextField.h"

@implementation TTTextField

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

-(void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    if (self.delegate && [self.delegate respondsToSelector:@selector(mouseDownDidOccurWithEvent:)])
        [(id)self.delegate mouseDownDidOccurWithEvent:theEvent]; // shitty cast but as long as we're careful with it it should be ok.
}

@end
