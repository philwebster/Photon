//
//  PTNLightController.m
//  Photon
//
//  Created by Philip Webster on 1/24/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNLightController.h"
#import "PNAppDelegate.h"
#import "PNUtilities.h"

#define MAX_HUE 65535

@interface PNLightController()

@property NSArray *xyNaturalColors;
@property NSArray *colors;

@property PHHueSDK *sdk;

@property NSArray *demoGroups;
@property NSArray *demoLights;
@property NSArray *demoScenes;

@end

@implementation PNLightController

+ (id)singleton {
    static PNLightController *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

- (id)init {
    self = [super init];
    if (self) {
        self.inDemoMode = NO;
        self.standardColors = @[[UIColor colorWithHue:0.626 saturation:0.871 brightness:1.000 alpha:1.000],
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
        
        NSMutableArray *tempGroups = [NSMutableArray new];
        NSMutableArray *tempLights = [NSMutableArray new];
        NSMutableArray *tempScenes = [NSMutableArray new];

        for (int i = 0; i < 6; ++i) {
            PHGroup *group = [PHGroup new];
            group.name = [NSString stringWithFormat:@"fake group %d", i];
            [tempGroups addObject:group];

            PHLight *light = [PHLight new];
            light.name = [NSString stringWithFormat:@"fake light %d", i];
            [tempLights addObject:light];
            
            PHScene *scene = [PHScene new];
            scene.name = [NSString stringWithFormat:@"fake scene %d", i];
            [tempScenes addObject:scene];
        }
        self.demoGroups = tempGroups;
        self.demoLights = tempLights;
        self.demoScenes = tempScenes;
    }
    return self;
}

- (void)setStateWithDict:(NSDictionary *)stateDict {
    // Maybe do this?
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
            CGPoint coord = [PNUtilities xyFromCT:ct];
            [lightState setX:[NSNumber numberWithDouble:coord.x]];
            [lightState setY:[NSNumber numberWithDouble:coord.y]];
        }
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:nil];
    } else if ([resource isKindOfClass:[PHGroup class]]) {
        PHGroup *group = (PHGroup *)resource;
        NSMutableSet *nonCTLights = [NSMutableSet new];
        for (NSString *identifier in group.lightIdentifiers) {
            PHLight *groupedLight = [self lightWithId:identifier];
            if (![groupedLight supportsCT]) {
                [nonCTLights addObject:groupedLight];
            }
        }
        [lightState setCt:ct];
        [lightState setOnBool:YES];
        [bridgeSendAPI setLightStateForGroupWithId:group.identifier lightState:lightState completionHandler:nil];
        CGPoint coord = [PNUtilities xyFromCT:ct];
        [lightState setX:[NSNumber numberWithDouble:coord.x]];
        [lightState setY:[NSNumber numberWithDouble:coord.y]];
        for (PHLight *light in nonCTLights) {
            [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:nil];
        }
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

- (void)setBrightness:(NSNumber *)brightness forResource:(PHBridgeResource *)resource {
    PHLightState *lightState = [[PHLightState alloc] init];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    [lightState setBrightness:brightness];
    if ([resource isKindOfClass:[PHLight class]]) {
        PHLight *light = (PHLight *)resource;
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:nil];
    } else if ([resource isKindOfClass:[PHGroup class]]) {
        PHGroup *group = (PHGroup *)resource;
        [bridgeSendAPI setLightStateForGroupWithId:group.identifier lightState:lightState completionHandler:nil];
    }
}

- (void)setScene:(PHScene *)scene onGroup:(PHGroup *)group {
    PHBridgeSendAPI *bridgeSendAPI = [PHBridgeSendAPI new];
    [bridgeSendAPI activateSceneWithIdentifier:scene.identifier onGroup:@"0" completionHandler:nil];
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

- (PHLight *)lightWithId:(NSString *)lightId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", lightId];
    NSArray *filteredArray = [self.lights filteredArrayUsingPredicate:predicate];
    PHLight *firstFoundObject = nil;
    firstFoundObject =  filteredArray.count > 0 ? filteredArray.firstObject : nil;
    return firstFoundObject;
}

- (NSArray *)lights {
    if (self.inDemoMode) {
        return self.demoLights;
    }
    return [[[PHBridgeResourcesReader readBridgeResourcesCache] lights] allValues];
}

- (NSArray *)groups {
    if (self.inDemoMode) {
        return self.demoGroups;
    }
    return [[[PHBridgeResourcesReader readBridgeResourcesCache] groups] allValues];
}

- (NSArray *)scenes {
    if (self.inDemoMode) {
        return self.demoScenes;
    }
    return [[[PHBridgeResourcesReader readBridgeResourcesCache] scenes] allValues];
}

@end
