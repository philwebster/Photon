//
//  PNColorPickerVC.h
//  Photon
//
//  Created by Philip Webster on 2/2/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNColorView.h"
#import <HueSDK_iOS/HueSDK.h>

@interface PNColorPickerVC : UIViewController <colorSelectionDelegate>

@property PHBridgeResource *resource;

@end
