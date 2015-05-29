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
@property (weak, nonatomic) IBOutlet WKInterfaceButton *offButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *colorButton;
@property id context;
@property (nonatomic, assign) BOOL labelOff;
@property (nonatomic, assign) BOOL colorEnabled;

@end

@implementation PNWatchLightSettingIC

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.context = context;

    // Configure interface objects here.
    self.labelOff = YES;
    if ([self.context respondsToSelector:@selector(isEqualToString:)]) {
        if ([self.context isEqualToString:@"adjust"]) {
            [self setTitle:@"Done"];
        }
    }

    if ([self.context class] == [PHGroup class] || [self.context class] == [PHLight class]) {
        self.resource = (PHBridgeResource *)self.context;
        self.lightController.lastUsedResource = self.resource;
        [self setTitle:self.resource.name];
    } else if ([self.context isEqualToString:@"adjust"]) {
        NSMutableArray *onLights = [NSMutableArray array];
        [self.lightController.onLights enumerateObjectsUsingBlock:^(PHLight *light, NSUInteger idx, BOOL *stop) {
            [onLights addObject:light.identifier];
        }];
        [self.lightController createNewGroupWithName:@"photon temp" lightIds:onLights completion:^(NSArray *errors) {
            self.resource = [self.lightController groupWithName:@"photon temp"];
            self.lightController.lastUsedResource = self.resource;
        }];
    }
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.phil.photon"];
    if ([[sharedDefaults stringForKey:@"loop resource"] isEqualToString:self.resource.name]) {
        [self.colorButton setTitle:@"Stop Color"];
        self.colorEnabled = YES;
    } else {
        [self.colorButton setTitle:@"Start Color"];
        self.colorEnabled = NO;
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self updateBrightnessSlider];
}

- (void)updateBrightnessSlider {
    CGFloat brightness = [self.resource isKindOfClass:[PHGroup class]] ? [[self.lightController averageBrightnessForGroup:(PHGroup *)self.resource] floatValue]: [((PHLight *)self.resource).lightState.brightness floatValue];
    [self.brightnessSlider setValue:brightness];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    if ([self.context respondsToSelector:@selector(isEqualToString:)]) {
        if ([self.context isEqualToString:@"adjust"] ) {
            [self.lightController deleteGroup:(PHGroup *)self.resource completion:nil];
        }
    }
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

- (IBAction)colorButtonPressed {
    if (self.colorEnabled) {
        [self.colorButton setTitle:@"Start Color"];
        [self.lightController stopColorLoop];
        self.colorEnabled = NO;
    } else {
        [self.colorButton setTitle:@"Stop Color"];
        [self.lightController startColorLoopForResource:self.resource transitionTime:60];
        self.colorEnabled = YES;
    }
}

- (IBAction)otherLightsPressed {
    if (self.labelOff) {
        [self.lightController setOtherResourcesOff];
        [self.otherLightsButton setTitle:@"Others ON"];
        self.labelOff = NO;
    } else {
        [self.lightController setOtherResourcesOn];
        [self.otherLightsButton setTitle:@"Others OFF"];
        self.labelOff = YES;
    }
}

- (IBAction)offButtonPressed {
    [self.lightController setResourceOff:self.resource];
}

@end



