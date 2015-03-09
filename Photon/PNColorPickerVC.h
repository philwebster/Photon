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
#import "PNBrightnessPickerVC.h"

@protocol colorPickerDelegate

- (void)dismissedColorPicker;

@end

@interface PNColorPickerVC : UIViewController <colorSelectionDelegate, brightnessSelectionDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) PHBridgeResource *resource;
@property id <colorPickerDelegate> colorDelegate;

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer;
- (void)dismissView;

@end
