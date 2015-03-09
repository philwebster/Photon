//
//  PNBrightnessPickerVC.h
//  Photon
//
//  Created by Philip Webster on 3/8/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HueSDK_iOS/HueSDK.h>

@protocol brightnessSelectionDelegate

- (void)brightnessUpdated:(NSNumber *)brightness;
- (void)finishedBrightnessSelection;

@end

@interface PNBrightnessPickerVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) PHBridgeResource *resource;
@property id <brightnessSelectionDelegate> delegate;

- (void)startFadingAfterInterval:(NSTimeInterval)interval;

@end
