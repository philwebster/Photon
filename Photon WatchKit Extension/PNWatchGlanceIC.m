//
//  PNWatchGlanceIC.m
//  Photon
//
//  Created by Philip Webster on 5/18/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNWatchGlanceIC.h"
#import "PNLightController.h"
#import "PNConstants.h"

@interface PNWatchGlanceIC ()

@property PNLightController *lightController;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lightsOnLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *numLightsOnLabel;

@end

@implementation PNWatchGlanceIC

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:kPNAppGroup];
    NSData *cacheData = [sharedDefaults dataForKey:@"phBridgeResourcesCache"];
    NSString *deviceID = [sharedDefaults stringForKey:@"uniqueGlobalDeviceIdentifier"];
    [[NSUserDefaults standardUserDefaults] setObject:cacheData forKey:@"phBridgeResourcesCache"];
    [[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:@"uniqueGlobalDeviceIdentifier"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.lightController = [PNLightController singleton];

}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];

    NSInteger numOn = self.lightController.onLights.count;

    [self.numLightsOnLabel setText:[NSString stringWithFormat:@"%ld", (long)numOn]];

    if (numOn == 1) {
        [self.lightsOnLabel setText:@"light on"];
    } else {
        [self.lightsOnLabel setText:@"lights on"];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



