//
//  TTTextView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/25/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTTextView.h"

@implementation TTTextView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//    // Drawing code here.
//}

// NSTextView's dont seem to want to update unless a redraw is called after the string has been set.

-(void)setString:(NSString *)string
{
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setString:string];
        });
    }
    else
        [super setString:string];
}

@end
