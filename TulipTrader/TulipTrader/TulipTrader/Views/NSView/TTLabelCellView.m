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
@property(nonatomic, retain)NSFont* labelFont;
@property(nonatomic, retain)NSMutableDictionary* labelStringPropertiesDictionary;


@end

@implementation TTLabelCellView


+(void)initialize
{
    if (self == [TTLabelCellView class])
    {

    }
}

-(void)setValueString:(NSString *)valueString
{
    _valueString = valueString;
    [self setNeedsDisplay:YES];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setLabelFont:[NSFont fontWithName:@"Menlo" size:12.f]]; // Menlo is better
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSCenterTextAlignment];
        _textColor = [NSColor blackColor];
        [self setLabelStringPropertiesDictionary:[NSMutableDictionary dictionaryWithDictionary:@{NSParagraphStyleAttributeName : style, NSFontAttributeName : self.labelFont, NSForegroundColorAttributeName : self.textColor}]];
    }
    return self;
}

-(void)setTextColor:(NSColor *)textColor
{
    _textColor = textColor;
    [self.labelStringPropertiesDictionary setObject:self.textColor forKey:NSForegroundColorAttributeName];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (self.valueString)
    {
        [self.valueString drawInRect:(NSRect){2, 4, CGRectGetWidth(self.frame) - 8, CGRectGetHeight(self.frame) - 4} withAttributes:self.labelStringPropertiesDictionary];
    }
}

@end
