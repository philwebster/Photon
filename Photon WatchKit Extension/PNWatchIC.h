//
//  PNWatchIC.h
//  Photon
//
//  Created by Philip Webster on 5/18/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "PNLightController.h"

@interface PNWatchIC : WKInterfaceController

@property PNLightController *lightController;

@end
