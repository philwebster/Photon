//
//  PNBrightnessCell.h
//  Photon
//
//  Created by Philip Webster on 4/4/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HueSDK_iOS/HueSDK.h>

@protocol lightBrightnessSliderDelegate

- (void)sliderChanged:(id)sender;

@end

@interface PNBrightnessCell : UITableViewCell

@property (strong, nonatomic) PHBridgeResource *resource;
@property (weak, nonatomic) id<lightBrightnessSliderDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISlider *resourceBrightnessSlider;

@end
