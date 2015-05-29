//
//  PNWatchIC.m
//  Photon
//
//  Created by Philip Webster on 5/18/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNWatchIC.h"
#import <Parse/Parse.h>

@interface PNWatchIC ()

@end

@implementation PNWatchIC

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self addMenuItemWithItemIcon:WKMenuItemIconDecline title:@"All Off" action:@selector(allOffTapped)];
    [self addMenuItemWithItemIcon:WKMenuItemIconAccept title:@"All On" action:@selector(allOnTapped)];
    // TODO: see if lights are already a group when going to adjust
    [self addMenuItemWithImageNamed:@"adjust" title:@"Adjust" action:@selector(adjustTapped)];
    // Configure interface objects here.
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.phil.photon"];
    NSData *cacheData = [sharedDefaults dataForKey:@"phBridgeResourcesCache"];
    NSString *deviceID = [sharedDefaults stringForKey:@"uniqueGlobalDeviceIdentifier"];
    [[NSUserDefaults standardUserDefaults] setObject:cacheData forKey:@"phBridgeResourcesCache"];
    [[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:@"uniqueGlobalDeviceIdentifier"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    self.lightController = [PNLightController singleton];

    BOOL demoMode = [sharedDefaults boolForKey:@"demoMode"];
    [[PNLightController singleton] setInDemoMode:demoMode];
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil) {
        if (!self.lightController.phHueSDK.localConnected) {
            [self.lightController.phHueSDK startUpSDK];
            [self.lightController.phHueSDK enableLocalConnection];
        }
    }

}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    [self.lightController.phHueSDK disableLocalConnection];
    [self.lightController.phHueSDK stopSDK];
}

- (void)allOffTapped {
    [self.lightController setResourceOff:self.lightController.allLightsGroup];
}

- (void)adjustTapped {
    [self presentControllerWithName:@"LightSettings" context:@"adjust"];
}

- (void)allOnTapped {
    [self.lightController setNaturalColor:@326 forResource:self.lightController.allLightsGroup];
    [self.lightController setBrightness:@253 forResource:self.lightController.allLightsGroup];
}

@end



