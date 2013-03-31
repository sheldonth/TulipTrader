//
//  TTGoxSocketController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 3/31/13.
//  Copyright (c) 2013 Resplendent G.P. Sheldon Thomas. All rights reserved.
//

#import "RUSingleton.h"
#import "SRWebSocket.h"

@interface TTGoxSocketController : NSObject <SRWebSocketDelegate>

-(void)open;

RU_SYNTHESIZE_SINGLETON_DECLARATION_FOR_CLASS_WITH_ACCESSOR(TTGoxSocketController, sharedInstance);

@end
