//
//  PNWatchBrightnessIC.m
//  Photon
//
//  Created by Philip Webster on 5/21/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNWatchBrightnessIC.h"

@interface PNWatchBrightnessIC ()
@property (weak, nonatomic) IBOutlet WKInterfaceSlider *brightnessSlider;

@end

@implementation PNWatchBrightnessIC

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    
    [self.brightnessSlider setValue:[[self.lightController averageBrightnessForLights:self.lightController.onLights] floatValue]];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)brightnessChanged:(float)value {
    for (PHLight *light in self.lightController.onLights) {
        [self.lightController setBrightness:[NSNumber numberWithInt:(int)value] forResource:light];
    }
}

@end



