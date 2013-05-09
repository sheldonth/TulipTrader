//
//  NSColor+Hex.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/9/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "NSColor+Hex.h"

@implementation NSColor (Hex)

+(NSColor*)colorWithHexString:(NSString*)string
{
    unsigned int value = 0;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    if ([[string substringToIndex:2] isEqualToString:@"0x"] && string.length == 8)
        [scanner setScanLocation:2];
    [scanner scanHexInt:&value];
    
    return [NSColor colorWithDeviceRed:((float)((value & 0xFF0000) >> 16))/255.0
                                 green:((float)((value & 0xFF00) >> 8))/255.0
                                  blue:((float)(value & 0xFF))/255.0
                                 alpha:1.0];
}

@end
