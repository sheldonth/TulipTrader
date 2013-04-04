//
//  TTGoxPrivateMessageController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/1/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUSingleton.h"
#import "TTGoxSocketController.h"

@interface TTGoxPrivateMessageController : NSObject <TTGoxSocketControllerMessageDelegate>


RU_SYNTHESIZE_SINGLETON_DECLARATION_FOR_CLASS_WITH_ACCESSOR(TTGoxPrivateMessageController, sharedInstance);
@end
