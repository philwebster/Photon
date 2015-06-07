
//
//  PTNLightController.m
//  Photon
//
//  Created by Philip Webster on 1/24/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNLightController.h"
#import "PNUtilities.h"
#import "PNConstants.h"
#import <Parse/Parse.h>

#define MAX_HUE 65535

#if TARGET_OS_IPHONE
#define PNColor UIColor
#elif TARGET_OS_MAC
#define PNColor NSColor
#endif

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
        

#ifdef TARGET_IS_EXTENSION
        [Parse enableDataSharingWithApplicationGroupIdentifier:kPNAppGroup
                                         containingApplication:kPNAppId];
        [Parse setApplicationId:kPNParseAppId
                      clientKey:kPNParseClientKey];
        [PFUser enableAutomaticUser];
        if (![PFUser currentUser]) {
            PFUser *user = [PFUser currentUser];
            [user saveInBackground];
        }
#endif

        self.phHueSDK = [[PHHueSDK alloc] init];

        self.standardColors = @[[PNColor colorWithHue:0.626 saturation:0.871 brightness:1.000 alpha:1.000],
                                [PNColor colorWithHue:0.788 saturation:1.000 brightness:1.000 alpha:1.000],
                                [PNColor colorWithHue:0.846 saturation:1.000 brightness:1.000 alpha:1.000],
                                [PNColor colorWithHue:0.965 saturation:1.000 brightness:1.000 alpha:1.000],
                                [PNColor colorWithHue:0.081 saturation:0.881 brightness:1.000 alpha:1.000],
                                [PNColor colorWithHue:0.155 saturation:0.941 brightness:1.000 alpha:1.000],
                                [PNColor colorWithHue:0.341 saturation:0.748 brightness:1.000 alpha:1.000],
                                [PNColor colorWithHue:0.468 saturation:0.808 brightness:1.000 alpha:1.000]];
        self.naturalColors = @[ [PNColor colorWithHue:0.123 saturation:0.665 brightness:0.996 alpha:1.000],
                                [PNColor colorWithHue:0.132 saturation:0.227 brightness:1.000 alpha:1.000],
                                [PNColor colorWithHue:0.167 saturation:0.012 brightness:1.000 alpha:1.000],
                                [PNColor colorWithHue:0.549 saturation:0.200 brightness:1.000 alpha:1.000],
                                [PNColor colorWithHue:0.540 saturation:0.409 brightness:0.922 alpha:1.000]];
        self.ctNaturalColors = @[@500, @413, @326, @240, @153];
        self.xyNaturalColors = @[@[@0.513, @0.4029], @[@0.513, @0.4029], @[@0.3114, @0.3296], @[@0.3114, @0.3296], @[@0.3114, @0.3296]];
        
        NSMutableArray *tempGroups = [NSMutableArray new];
        NSMutableArray *tempLights = [NSMutableArray new];
        NSMutableArray *tempScenes = [NSMutableArray new];

        for (int i = 0; i < 6; ++i) {
            PHGroup *group = [PHGroup new];
            group.name = [NSString stringWithFormat:@"Group %d", i];
            group.lightIdentifiers = @[@"1", @"2", @"3"];
            [tempGroups addObject:group];

            PHLight *light = [PHLight new];
            light.name = [NSString stringWithFormat:@"Light %d", i];
            light.identifier = [NSString stringWithFormat:@"%d", i];

            PHLightState *lightState = [[PHLightState alloc] init];
            [lightState setBrightness:[NSNumber numberWithInt:arc4random_uniform(256)]];
            [lightState setOnBool:YES];
            light.lightState = lightState;
            
            [tempLights addObject:light];
            
            PHScene *scene = [PHScene new];
            scene.name = [NSString stringWithFormat:@"Scene %d", i];
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
        [lightState setOnBool:YES];
        if ([light supportsCT]) {
            [lightState setCt:ct];
        } else if ([light supportsColor]) {
            CGPoint coord = [PNUtilities xyFromCT:ct];
            [lightState setX:[NSNumber numberWithDouble:coord.x]];
            [lightState setY:[NSNumber numberWithDouble:coord.y]];
        }
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            self.lastUsedResource = light;
        }];
    } else if ([resource isKindOfClass:[PHGroup class]]) {
        PHGroup *group = (PHGroup *)resource;
        NSMutableSet *nonCTLights = [NSMutableSet new];
        for (NSString *identifier in group.lightIdentifiers) {
            PHLight *groupedLight = [self lightWithId:identifier];
            if (![groupedLight supportsCT] && groupedLight) {
                [nonCTLights addObject:groupedLight];
            }
        }
        [lightState setCt:ct];
        [lightState setOnBool:YES];
        [bridgeSendAPI setLightStateForGroupWithId:group.identifier lightState:lightState completionHandler:^(NSArray *errors) {
            self.lastUsedResource = group;
        }];
        CGPoint coord = [PNUtilities xyFromCT:ct];
        [lightState setX:[NSNumber numberWithDouble:coord.x]];
        [lightState setY:[NSNumber numberWithDouble:coord.y]];
        for (PHLight *light in nonCTLights) {
            [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:nil];
        }
    }
}

- (void)setColor:(PNColor *)color forResource:(PHBridgeResource *)resource transitionTime:(NSNumber *)transitionTime completion:(void (^)(NSArray *errors))completion {
    
    PHLightState *lightState = [[PHLightState alloc] init];
    
    CGFloat hue, sat, brightness, alpha;
    [color getHue:&hue saturation:&sat brightness:&brightness alpha:&alpha];
    [lightState setHue:[NSNumber numberWithInt:hue * MAX_HUE]];
    [lightState setSaturation:[NSNumber numberWithInt:254]];
    [lightState setOnBool:YES];
    if (transitionTime) {
        int correctedTransition = [transitionTime intValue] * 10;
        [lightState setTransitionTime:[NSNumber numberWithInt:correctedTransition]];
    }
    
    // Send lightstate to light
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    if ([resource isKindOfClass:[PHLight class]]) {
        [bridgeSendAPI updateLightStateForId:resource.identifier withLightState:lightState completionHandler:completion];
    } else if ([resource isKindOfClass:[PHGroup class]]) {
        [bridgeSendAPI setLightStateForGroupWithId:resource.identifier lightState:lightState completionHandler:completion];
    }
}

- (void)setBrightness:(NSNumber *)brightness forResource:(PHBridgeResource *)resource {
    PHLightState *lightState = [[PHLightState alloc] init];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    [lightState setBrightness:brightness];
    [lightState setOnBool:YES];
    if ([resource isKindOfClass:[PHLight class]]) {
        PHLight *light = (PHLight *)resource;
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {

        }];
    } else if ([resource isKindOfClass:[PHGroup class]]) {
        PHGroup *group = (PHGroup *)resource;
        [bridgeSendAPI setLightStateForGroupWithId:group.identifier lightState:lightState completionHandler:^(NSArray *errors) {
            
        }];
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

- (PHGroup *)groupWithName:(NSString *)name {
    for (PHGroup *group in self.groups) {
        if ([group.name isEqualToString:name]) {
            return group;
        }
    }
    return nil;
}

- (PHLight *)lightWithName:(NSString *)name {
    for (PHLight *light in self.lights) {
        if ([light.name isEqualToString:name]) {
            return light;
        }
    }
    return nil;
}

- (NSArray *)lightsForGroup:(PHGroup *)group {
    __block NSMutableArray *lights = [NSMutableArray array];
    [group.lightIdentifiers enumerateObjectsUsingBlock:^(NSString *lightID, NSUInteger idx, BOOL *stop) {
        PHLight *light = [self lightWithId:lightID];
        [lights addObject:light];
    }];
    return lights;
}

- (NSNumber *)averageBrightnessForGroup:(PHGroup *)group {
    __block NSInteger average = 0;
    [group.lightIdentifiers enumerateObjectsUsingBlock:^(NSString *lightID, NSUInteger idx, BOOL *stop) {
        PHLight *light = [self lightWithId:lightID];
        average += [light.lightState.brightness integerValue];
    }];
    average = average / group.lightIdentifiers.count;
    return [NSNumber numberWithInteger:average];
}

- (NSNumber *)averageBrightnessForLights:(NSArray *)lights {
    __block NSInteger average = 0;
    [lights enumerateObjectsUsingBlock:^(PHLight *light, NSUInteger idx, BOOL *stop) {
        average += [light.lightState.brightness integerValue];
    }];
    average = average / lights.count;
    return [NSNumber numberWithInteger:average];
}

- (PHBridgeResource *)allLightsGroup {
    PHGroup *allLightsGroup = [PHGroup new];
    allLightsGroup.identifier = @"0";
    return allLightsGroup;
}

- (void)updateGroup:(PHGroup *)group completion:(void (^)(NSArray *errors))completion {
    if (self.inDemoMode) {
        return;
    }
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    [bridgeSendAPI updateGroupWithGroup:group completionHandler:^(NSArray *errors) {
        if (completion) {
            completion(errors);
        }
    }];
}

- (void)updateLight:(PHLight *)light completion:(void (^)(NSArray *errors))completion {
    if (self.inDemoMode) {
        return;
    }
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    [bridgeSendAPI updateLightWithLight:light completionHandler:^(NSArray *errors) {
        if (completion) {
            completion(errors);
        }
    }];
}

- (void)createNewGroupWithName:(NSString *)name lightIds:(NSArray *)lightIds completion:(void (^)(NSArray *errors))completion {
    if (self.inDemoMode) {
        PHGroup *group = [PHGroup new];
        group.name = name;
        group.lightIdentifiers = lightIds;

        NSMutableArray *array = [self.groups mutableCopy];
        [array addObject:group];
        self.groups = array;
        return;
    }
    
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    [bridgeSendAPI createGroupWithName:name lightIds:lightIds completionHandler:^(NSString *groupIdentifier, NSArray *errors) {
        if (completion) {
            completion(errors);
        }
    }];
}

- (void)deleteGroup:(PHGroup *)group completion:(void (^)(NSArray *errors))completion {
    if (self.inDemoMode) {
        NSMutableArray *array = [self.groups mutableCopy];
        [array removeObject:group];
        self.groups = array;
        return;
    }
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    [bridgeSendAPI removeGroupWithId:group.identifier completionHandler:^(NSArray *errors) {
        if (completion) {
            completion(errors);
        }
    }];
}

- (void)resetPhoton {
    self.inDemoMode = NO;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"phBridgeResourcesCache"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uniqueGlobalDeviceIdentifier"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:kPNAppGroup];
    [sharedDefaults removeObjectForKey:@"phBridgeResourcesCache"];
    [sharedDefaults removeObjectForKey:@"uniqueGlobalDeviceIdentifier"];
    [sharedDefaults synchronize];
}

- (void)setInDemoMode:(BOOL)inDemoMode {
    inDemoMode = inDemoMode;
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:kPNAppGroup];
    [sharedDefaults setBool:inDemoMode forKey:kPNDemoModeKey];
    [sharedDefaults synchronize];
}

- (BOOL)inDemoMode {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:kPNAppGroup];
    return [sharedDefaults boolForKey:kPNDemoModeKey];
}

- (void)setOtherResourcesOff {
    PHLightState *lightState = [PHLightState new];
    [lightState setOnBool:NO];
    [self setState:lightState forLights:[self otherResources]];
}

- (void)setOtherResourcesOn {
    PHLightState *lightState = [PHLightState new];
    [lightState setOnBool:YES];
    [self setState:lightState forLights:[self otherResources]];
}

- (void)setState:(PHLightState *)state forLights:(NSArray *)lights {
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    for (PHLight *light in lights) {
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:state completionHandler:nil];
    }
}

- (NSArray *)otherResources {
    NSMutableArray *lightsToRemove = [NSMutableArray array];
    if ([self.lastUsedResource isKindOfClass:[PHLight class]]) {
        [lightsToRemove addObject:self.lastUsedResource.identifier];
    } else if ([self.lastUsedResource isKindOfClass:[PHGroup class]]) {
        for (PHLight *light in [self lightsForGroup:(PHGroup *)self.lastUsedResource]) {
            [lightsToRemove addObject:light.identifier];
        }
    }
  
    NSMutableArray *lightsToSet = [NSMutableArray array];
    for (PHLight *light in self.lights) {
        if (![lightsToRemove containsObject:light.identifier]) {
            [lightsToSet addObject:light];
        }
    }
    
    return lightsToSet;
}

- (NSArray *)onLights {
    NSMutableArray *lights = [NSMutableArray array];
    for (PHLight *light in self.lights) {
        if ([light.lightState.on boolValue]) {
            [lights addObject:light];
        }
    }
    return lights;
}

- (void)startColorLoopForResource:(PHBridgeResource *)resource transitionTime:(NSInteger)transitionTime {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:kPNAppGroup];
    BOOL alreadyLooping = [sharedDefaults objectForKey:kPNLoopResourceNameKey];
    [sharedDefaults setObject:resource.name forKey:kPNLoopResourceNameKey];
    [sharedDefaults setObject:NSStringFromClass([resource class]) forKey:kPNLoopResourceTypeKey];
    [sharedDefaults setInteger:self.standardColors.count - 1 forKey:kPNLoopStateKey];
    [sharedDefaults synchronize];
    __weak PNLightController *weakSelf = self;
    [self setColor:self.standardColors.lastObject forResource:resource transitionTime:nil completion:^(NSArray *errors) {
        if (!alreadyLooping) {
            [weakSelf stepColorLoopCompletion:nil];
        }
    }];
}

- (void)stepColorLoopCompletion:(void (^)())completion {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:kPNAppGroup];
    if (![sharedDefaults stringForKey:kPNLoopResourceNameKey]) {
        if (completion) {
            completion();
        }
        return;
    }

    NSInteger lastColorIndex = [sharedDefaults integerForKey:kPNLoopStateKey];
    NSInteger nextColor = lastColorIndex == self.standardColors.count - 1 ? 0 : lastColorIndex + 1;
    [sharedDefaults setInteger:nextColor forKey:kPNLoopStateKey];
    [sharedDefaults synchronize];
    NSInteger transitionTime = [sharedDefaults integerForKey:kPNLoopDurationKey];
    PHBridgeResource *loopingResource;

    NSString *resourceType = [sharedDefaults stringForKey:kPNLoopResourceTypeKey];
    NSString *resourceName = [sharedDefaults stringForKey:kPNLoopResourceNameKey];
    if ([resourceType isEqualToString:NSStringFromClass([PHGroup class])]) {
        loopingResource = [self groupWithName:resourceName];
    } else if ([resourceType isEqualToString:NSStringFromClass([PHLight class])]) {
        loopingResource = [self lightWithName:resourceName];
    }
    __weak PNLightController *weakSelf = self;
    
    [self setColor:self.standardColors[nextColor] forResource:loopingResource transitionTime:@(transitionTime) completion:^(NSArray *errors) {
#ifndef MACOSX_DEPLOYMENT_TARGET
        [weakSelf initiatePushUpdateWithInterval:transitionTime completion:completion];
#else
        if (completion) {
            completion(errors);
        }
#endif
    }];
}

- (void)stopColorLoop {
    // TODO: handle starting/stopping quickly and prevent multiple push notifications being sent
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:kPNAppGroup];
    [sharedDefaults removeObjectForKey:kPNLoopResourceTypeKey];
    [sharedDefaults removeObjectForKey:kPNLoopResourceNameKey];
    [sharedDefaults removeObjectForKey:kPNLoopStateKey];
    [sharedDefaults synchronize];
}

- (void)initiatePushUpdateWithInterval:(NSInteger)interval completion:(void (^)())completion {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:kPNAppGroup];
    NSDate *expectedPush = [sharedDefaults objectForKey:kPNScheduledPushDateKey];
    if ([[NSDate date] timeIntervalSinceDate:expectedPush] < 0) {
        if (completion) {
            completion();
        }
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *scheduledDate = [NSDate dateWithTimeIntervalSinceNow:interval];
    NSString *scheduledDateString = [dateFormatter stringFromDate:scheduledDate];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@{@"deviceToken": @{@"$in": @[[PFInstallation currentInstallation].deviceToken]}} forKey:@"where"];
    [params setObject:scheduledDateString forKey:@"push_time"];
    [params setObject:@{@"aps": @{@"content-available":@1}} forKey:@"data"];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.parse.com/1/push"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[Parse getApplicationId] forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request setValue:kPNParseRESTAPIKey forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:kPNAppGroup];
        [sharedDefaults setObject:scheduledDate forKey:kPNScheduledPushDateKey];
        [sharedDefaults synchronize];
        if (completion) {
            completion();
        }
    }];
    
    [postDataTask resume];
}

@end
