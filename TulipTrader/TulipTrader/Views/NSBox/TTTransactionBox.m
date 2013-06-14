//
//  TTTransactionBox.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 6/6/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import "TTTransactionBox.h"

@implementation TTTransactionBox

static NSDateFormatter* dateFormatter;

+(void)initialize
{
    dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MM/dd/YYYY HH:mm:ss"];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBorderWidth:2.f];
        [self setBorderColor:[NSColor blackColor]];
    }
    
    return self;
}

-(void)setTransaction:(Transaction *)transaction
{
    [self setTitle:[dateFormatter stringFromDate:transaction.date]];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

@end
