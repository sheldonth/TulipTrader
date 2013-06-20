//
//  TTOperationsController.h
//  TulipTrader
//
//  Created by Sheldon Thomas on 4/1/13.
//  Copyright (c) 2013  Sheldon Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTGoxSocketController.h"
#import "TTGoxPrivateMessageController.h"
#import "TTGoxResultMessageController.h"
#import "TTOERatesController.h"

@interface TTOperationsController : NSObject <TTGoxSocketControllerMessageDelegate>

@property(nonatomic, retain) TTGoxSocketController* socketController;
@property(nonatomic, retain) TTGoxPrivateMessageController* privateMessageController;
@property(nonatomic, retain) TTGoxResultMessageController* resultMessageController;
@property(nonatomic, retain) TTOERatesController* oeRatesController;

@end
