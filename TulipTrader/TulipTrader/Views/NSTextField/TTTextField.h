//
//  TTTextField.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 5/21/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol TTTextFieldDelegate <NSTextFieldDelegate>

-(void)mouseDownDidOccurWithEvent:(NSEvent*)theEvent;

@end

@interface TTTextField : NSTextField

@end
