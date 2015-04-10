//
//  PNBrightnessCell.m
//  Photon
//
//  Created by Philip Webster on 4/4/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNBrightnessCell.h"

@interface PNBrightnessCell ()

@property (weak, nonatomic) IBOutlet UILabel *resourceNameLabel;

@end

@implementation PNBrightnessCell

- (void)awakeFromNib {
    // Initialization code
    [self.resourceBrightnessSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setResource:(PHBridgeResource *)resource {
    if ([resource isKindOfClass:[PHLight class]]) {
        PHLight *light = (PHLight *)resource;
        self.resourceNameLabel.text = light.name;
        self.resourceBrightnessSlider.value = [light.lightState.brightness floatValue];
        _resource = resource;
    }
}

- (IBAction)sliderSlid:(id)sender {
    [self.delegate sliderChanged:self];
}

@end
