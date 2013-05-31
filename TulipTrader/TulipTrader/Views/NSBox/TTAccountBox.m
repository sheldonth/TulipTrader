//
//  TTAccountBox.m
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/30/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "TTAccountBox.h"
#import "TTGoxHTTPController.h"
#import "RUConstants.h"
#import "TTTextView.h"
#import "TTGoxAccount.h"

@interface TTAccountBox()

@property(nonatomic, retain)TTGoxHTTPController* httpController;
@property(nonatomic, retain)TTTextView* accountDataTextView;

@end

@implementation TTAccountBox

static NSDateFormatter* dateFormatter;

+(void)initialize
{
    dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
}

NSString* accountToString(TTGoxAccount* account)
{
    NSMutableString* outputStr = [NSMutableString string];
    [outputStr appendFormat:@"Username: %@\n", account.username];
    [outputStr appendFormat:@"Last Login: %@\n", [dateFormatter stringFromDate:account.loginDate]];
    [outputStr appendFormat:@"Monthly Volume: %@\n", account.monthlyVolume.display_short];
    if (account.permissionsArray.count == 5)
        [outputStr appendString:@"Rights : All"];
    else
    {
        [outputStr appendFormat:@"Rights: "];
        for (NSString* s in account.permissionsArray) {
            [outputStr appendFormat:@"%@ ", s];
        }
    }
    [outputStr appendFormat:@"\nCurrent Trade Fee: %@%%", account.tradeFee.stringValue];
    return outputStr;
}

-(void)getAccountData
{
    [_httpController loadAccountDataWithCompletion:^(NSDictionary* accountInformation) {
        [self setAccount:accountFromDictionary(accountInformation)];
        [_accountDataTextView setString:accountToString(self.account)];
    } andFailBlock:^(NSError *e) {
        
    }];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBorderWidth:2.f];
        [self setBorderColor:[NSColor blackColor]];
        [self setTitle:@"Accounts"];
        
        [self setHttpController:[TTGoxHTTPController sharedInstance]];
        [self getAccountData];
    }
    return self;
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    NSRect contentFrame = [(NSView*)self.contentView frame];
    CGFloat columnWidth = floorf(CGRectGetWidth(contentFrame) / 4);
    NSRect f = (NSRect){0, 0, columnWidth, CGRectGetHeight(contentFrame)};
    if (!self.accountDataTextView)
    {
        [self setAccountDataTextView:[[TTTextView alloc]initWithFrame:f]];
        [_accountDataTextView setDrawsBackground:NO];
        [_accountDataTextView setFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]];
        [self.contentView addSubview:_accountDataTextView];
    }
    else
        [self.accountDataTextView setFrame:f];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
//    [[NSColor orangeColor] setFill];
//    NSRectFill(dirtyRect);
}

@end
