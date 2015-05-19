//
//  InterfaceController.m
//  Photon WatchKit Extension
//
//  Created by Philip Webster on 1/22/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "InterfaceController.h"
#import "ResourceRowController.h"
#import "PNLightController.h"
#import <HueSDK_iOS/HueSDK.h>
#import "UIColor+PNUtilities.h"

@interface InterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceTable *ResourceTable;
@property id context;
@property NSArray *tableData;
@property PNLightController *lightController;
@property PHHueSDK *sdk;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self addMenuItemWithItemIcon:WKMenuItemIconDecline title:@"All Off" action:@selector(allOffTapped)];
    [self addMenuItemWithItemIcon:WKMenuItemIconAccept title:@"All On" action:@selector(allOnTapped)];
    self.lightController = [PNLightController singleton];
    self.context = context;
    if ([context respondsToSelector:@selector(isEqualToString:)]) {
        if ([context isEqualToString:@"Groups"])
            self.tableData = self.lightController.groups;
        else if ([context isEqualToString:@"Lights"])
            self.tableData = self.lightController.lights;
        else if ([context isEqualToString:@"Scenes"])
            self.tableData = self.lightController.scenes;
    } else {
        self.tableData = @[@"Groups", @"Lights"];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];

    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.phil.photon"];
    NSData *cacheData = [sharedDefaults dataForKey:@"phBridgeResourcesCache"];
    NSString *deviceID = [sharedDefaults stringForKey:@"uniqueGlobalDeviceIdentifier"];
    [[NSUserDefaults standardUserDefaults] setObject:cacheData forKey:@"phBridgeResourcesCache"];
    [[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:@"uniqueGlobalDeviceIdentifier"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    BOOL demoMode = [sharedDefaults boolForKey:@"demoMode"];
    [[PNLightController singleton] setInDemoMode:demoMode];
    
    self.sdk = self.lightController.phHueSDK;
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil) {
        if (!self.sdk.localConnected) {
            [self.sdk startUpSDK];
            [self.sdk enableLocalConnection];
        }
    }
    
    [self loadResourceItems];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
//    [self.sdk disableLocalConnection];
//    [self.sdk stopSDK];
}

- (void)loadResourceItems {
    [self.ResourceTable setNumberOfRows:self.tableData.count withRowType:@"default"];
    NSInteger rowCount = self.ResourceTable.numberOfRows;
    
    // Iterate over the rows and set the label for each one.
    for (NSInteger i = 0; i < rowCount; i++) {
        ResourceRowController* row = [self.ResourceTable rowControllerAtIndex:i];
        NSString *itemText;
        if ([self.context class] == [PHLight class] || [self.context class] == [PHGroup class]) {
            [row.rowGroup setBackgroundColor:[self.tableData objectAtIndex:i]];
            continue;
        } else if ([self.context respondsToSelector:@selector(isEqualToString:)]) {
            if ([self.context isEqualToString:@"Lights"]) {
                itemText = [(PHBridgeResource *)self.lightController.lights[i] name];
            } else if ([self.context isEqualToString:@"Groups"]) {
                itemText = [(PHBridgeResource *)self.lightController.groups[i] name];
            } else if ([self.context isEqualToString:@"Scenes"]) {
                itemText = [(PHBridgeResource *)self.lightController.scenes[i] name];
            }
        } else {
            itemText = self.tableData[i];
        }
        [row.resourceType setText:itemText];
        
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    if ([self.context class] == [PHLight class] || [self.context class] == [PHGroup class]) {
        [self.lightController setNaturalColor:[UIColor tempFromColor:[self.lightController.naturalColors objectAtIndex:rowIndex]] forResource:(PHBridgeResource *)self.context];
    }
    NSLog(@"tapped row");
}

- (void)allOffTapped {
    [self.lightController setResourceOff:self.lightController.allLightsGroup];
}

- (void)allOnTapped {
    [self.lightController setNaturalColor:@326 forResource:self.lightController.allLightsGroup];
    [self.lightController setBrightness:@253 forResource:self.lightController.allLightsGroup];
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
    if ([self.context class] == [NSString class]) {
        if ([self.context isEqualToString:@"Groups"]) {
            return self.lightController.groups[rowIndex];
        } else if ([self.context isEqualToString:@"Lights"]) {
            return self.lightController.lights[rowIndex];
        }
    }
    return self.tableData[rowIndex];
}

//- (IBAction)brightnessSliderChanged:(float)value {
//    [self.lightController setBrightness:[NSNumber numberWithInt:(int)value] forResource:(PHBridgeResource *)self.context];
//}


/**
 Notification receiver for successful local connection
 */
- (void)localConnection {
    // Check current connection state
}

/**
 Notification receiver for failed local connection
 */
- (void)noLocalConnection {
    // Check current connection state
}

/**
 Notification receiver for failed local authentication
 */
- (void)notAuthenticated {
    if ([[PNLightController singleton] inDemoMode]) {
        return;
    }
}

@end



