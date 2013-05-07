//
//  NSView+Utility.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/7/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "NSView+Utility.h"

@implementation NSView (Utility)

#pragma mark Increase frame methods
-(void)increaseWidth:(CGFloat)width
{
    [self setWidth:self.frame.size.width + width];
}

-(void)increaseHeight:(CGFloat)height
{
    [self setHeight:self.frame.size.height + height];
}

-(void)increaseWidth:(CGFloat)width height:(CGFloat)height
{
    [self setWidth:self.frame.size.width + width height:self.frame.size.height + height];
}

-(void)setWidth:(CGFloat)width
{
    [self setWidth:width height:self.frame.size.height];
}

-(void)setHeight:(CGFloat)height
{
    [self setWidth:self.frame.size.width height:height];
}

-(void)setWidth:(CGFloat)width height:(CGFloat)height
{
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height)];
}

-(void)setSize:(CGSize)size
{
    [self setWidth:size.width height:size.height];
}

@end
