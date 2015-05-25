//
//  PNResourceSettingVC.h
//  Photon
//
//  Created by Philip Webster on 5/25/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNLightController.h"
#import "PNColorView.h"
#import "PNBrightnessPickerVC.h"

@interface PNResourceSettingVC : UIViewController <colorSelectionDelegate, brightnessSelectionDelegate>

@property (weak, nonatomic) PHBridgeResource *resource;

@end
