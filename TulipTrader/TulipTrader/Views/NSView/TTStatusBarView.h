//
//  TTStatusBarView.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/5/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTGoxPrivateMessageController.h"

@interface TTStatusBarView : NSView <TTGoxPrivateMessageControllerLagDelegate, TTGoxPrivateMessageControllerTradesDelegate>

@end
