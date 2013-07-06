//
//  TTLabelCellView.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 7/2/13.
//  Copyright (c) 2013 Sheldon Thomas. All rights reserved.
//

#import "TTLabelCellView.h"

@interface TTLabelCellView()
{
    NSPoint valueStringPoint;
}

@end

@implementation TTLabelCellView

static NSFont* labelFont;
static NSDictionary* labelStringPropertiesDictionary;

+(void)initialize
{
    if (self == [TTLabelCellView class])
    {
        labelFont = [NSFont fontWithName:@"Menlo" size:12.f]; // Menlo is better
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSCenterTextAlignment];
        labelStringPropertiesDictionary = @{NSParagraphStyleAttributeName : style, NSFontAttributeName : labelFont};
    }
}

-(void)setValueString:(NSString *)valueString
{
    _valueString = valueString;
    [self setNeedsDisplay:YES];
//    CGFloat characterWidth = 10.f;
//    if (valueString.floatValue < 10.f)
//    {
//        valueStringPoint = (NSPoint){3 * characterWidth, 2};
//    }
//    else if (valueString.floatValue < 100.f)
//    {
//        valueStringPoint = (NSPoint){2 * characterWidth, 2};
//    }
//    else if (valueString.floatValue < 1000.f)
//    {
//        valueStringPoint = (NSPoint){1 * characterWidth, 2};
//    }
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
//    NSBezierPath* bPath = [NSBezierPath bezierPathWithRect:(NSRect){2, 2, self.frame.size.width - 4, self.frame.size.height - 2}];
//    [bPath setLineWidth:2.f];
//    [[NSColor lightGrayColor]set];
//    [bPath stroke];
    
    if (self.valueString)
    {
        [self.valueString drawInRect:(NSRect){2, 4, CGRectGetWidth(self.frame) - 8, CGRectGetHeight(self.frame) - 4} withAttributes:labelStringPropertiesDictionary];
//        [self.valueString drawAtPoint:valueStringPoint withAttributes:labelStringPropertiesDictionary];
    }
}

@end
