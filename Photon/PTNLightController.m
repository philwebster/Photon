//
//  PTNLightController.m
//  Photon
//
//  Created by Philip Webster on 1/24/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PTNLightController.h"

#define MAX_HUE 65535

@interface PTNLightController()

@property NSArray *xyNaturalColors;
@property NSArray *colors;

@property PHHueSDK *sdk;

@end

@implementation PTNLightController

- (id)init {
    self = [super init];
    if (self) {
        self.standardColors = @[[UIColor blackColor],
                                [UIColor colorWithHue:0.626 saturation:0.871 brightness:1.000 alpha:1.000],
                                [UIColor colorWithHue:0.788 saturation:1.000 brightness:0.996 alpha:1.000],
                                [UIColor colorWithHue:0.846 saturation:1.000 brightness:0.984 alpha:1.000],
                                [UIColor colorWithHue:0.965 saturation:1.000 brightness:0.984 alpha:1.000],
                                [UIColor colorWithHue:0.081 saturation:0.881 brightness:0.992 alpha:1.000],
                                [UIColor colorWithHue:0.155 saturation:0.941 brightness:0.996 alpha:1.000],
                                [UIColor colorWithHue:0.341 saturation:0.748 brightness:1.000 alpha:1.000],
                                [UIColor colorWithHue:0.468 saturation:0.808 brightness:1.000 alpha:1.000]];
        self.naturalColors = @[ [UIColor colorWithHue:0.123 saturation:0.665 brightness:0.996 alpha:1.000],
                                [UIColor colorWithHue:0.132 saturation:0.227 brightness:1.000 alpha:1.000],
                                [UIColor colorWithHue:0.167 saturation:0.012 brightness:1.000 alpha:1.000],
                                [UIColor colorWithHue:0.549 saturation:0.200 brightness:1.000 alpha:1.000],
                                [UIColor colorWithHue:0.540 saturation:0.409 brightness:0.922 alpha:1.000]];
        self.ctNaturalColors = @[@500, @413, @326, @240, @153];
        self.xyNaturalColors = @[@[@0.513, @0.4029], @[@0.513, @0.4029], @[@0.3114, @0.3296], @[@0.3114, @0.3296], @[@0.3114, @0.3296]];
    }
    return self;
}

- (void)setNaturalColor:(NSNumber *)ct forResource:(PHBridgeResource *)resource {
    // TODO: set natural color should maybe only be called for lights that can handle it and put the extra logic somewhere else.
    PHLightState *lightState = [[PHLightState alloc] init];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    if ([resource isKindOfClass:[PHLight class]]) {
        PHLight *light = (PHLight *)resource;
        if ([light supportsCT]) {
            [lightState setCt:ct];
            [lightState setOnBool:YES];
        } else if ([light supportsColor]) {
            [lightState setX:[_xyNaturalColors objectAtIndex:[_ctNaturalColors indexOfObject:ct]][0]];
            [lightState setX:[_xyNaturalColors objectAtIndex:[_ctNaturalColors indexOfObject:ct]][1]];
        } else {
            [lightState setBrightness:@254];
        }
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:nil];
    } else if ([resource isKindOfClass:[PHGroup class]]) {
        [bridgeSendAPI setLightStateForGroupWithId:resource.identifier lightState:lightState completionHandler:nil];
    }
}

- (void)setColor:(UIColor *)color forResource:(PHBridgeResource *)resource {
    
    PHLightState *lightState = [[PHLightState alloc] init];
    
    CGFloat hue, sat, brightness, alpha;
    [color getHue:&hue saturation:&sat brightness:&brightness alpha:&alpha];
    [lightState setHue:[NSNumber numberWithInt:hue * MAX_HUE]];
    [lightState setBrightness:[NSNumber numberWithInt:254]];
    [lightState setSaturation:[NSNumber numberWithInt:254]];
    [lightState setOnBool:YES];
    
    // Send lightstate to light
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    if ([resource isKindOfClass:[PHLight class]]) {
        [bridgeSendAPI updateLightStateForId:resource.identifier withLightState:lightState completionHandler:nil];
    } else if ([resource isKindOfClass:[PHGroup class]]) {
        [bridgeSendAPI setLightStateForGroupWithId:resource.identifier lightState:lightState completionHandler:nil];
    }
}

- (void)setResourceOff:(PHBridgeResource *)resource {
    PHLightState *lightState = [[PHLightState alloc] init];
    [lightState setOnBool:NO];
    
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    if ([resource isKindOfClass:[PHLight class]]) {
        [bridgeSendAPI updateLightStateForId:resource.identifier withLightState:lightState completionHandler:nil];
    } else if ([resource isKindOfClass:[PHGroup class]]) {
        [bridgeSendAPI setLightStateForGroupWithId:resource.identifier lightState:lightState completionHandler:nil];
    }
}

@end
