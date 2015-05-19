//
//  PNWatchLightSettingIC.m
//  Photon
//
//  Created by Philip Webster on 5/8/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNWatchLightSettingIC.h"
#import "PNLightController.h"
#import <HueSDK_iOS/HueSDK.h>
#import "UIColor+PNUtilities.h"
#import "ResourceRowController.h"

@interface PNWatchLightSettingIC ()

@property PHBridgeResource *resource;
@property NSArray *tableData;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *otherLightsButton;
@property (weak, nonatomic) IBOutlet WKInterfaceSlider *brightnessSlider;
@property (nonatomic, assign) BOOL labelOff;

@end

@implementation PNWatchLightSettingIC

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    if ([context class] == [PHGroup class] || [context class] == [PHLight class]) {
        self.resource = (PHBridgeResource *)context;
    }
    // Configure interface objects here.
    self.labelOff = YES;
    CGFloat brightness = [self.resource isKindOfClass:[PHGroup class]] ? [[self.lightController averageBrightnessForGroup:(PHGroup *)self.resource] floatValue]: [((PHLight *)self.resource).lightState.brightness floatValue];
    [self.brightnessSlider setValue:brightness];
    [self setTitle:self.resource.name];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)buttonAPressed {
    [self.lightController setNaturalColor:[UIColor tempFromColor:[self.lightController.naturalColors objectAtIndex:0]] forResource:self.resource];
}

- (IBAction)buttonBPressed {
    [self.lightController setNaturalColor:[UIColor tempFromColor:[self.lightController.naturalColors objectAtIndex:1]] forResource:self.resource];
}

- (IBAction)buttonCPressed {
    [self.lightController setNaturalColor:[UIColor tempFromColor:[self.lightController.naturalColors objectAtIndex:2]] forResource:self.resource];
}

- (IBAction)buttonDPressed {
    [self.lightController setNaturalColor:[UIColor tempFromColor:[self.lightController.naturalColors objectAtIndex:3]] forResource:self.resource];
}

- (IBAction)buttonEPressed {
    [self.lightController setNaturalColor:[UIColor tempFromColor:[self.lightController.naturalColors objectAtIndex:4]] forResource:self.resource];
}

- (IBAction)brightnessChanged:(float)value {
    [self.lightController setBrightness:[NSNumber numberWithInt:(int)value] forResource:self.resource];
}

- (IBAction)otherLightsPressed {
    if (self.labelOff) {
        [self.lightController setOtherResourcesOff];
        [self.otherLightsButton setTitle:@"Other Lights ON"];
        self.labelOff = NO;
    } else {
        [self.lightController setOtherResourcesOn];
        [self.otherLightsButton setTitle:@"Other Lights OFF"];
        self.labelOff = YES;
    }
}

@end



