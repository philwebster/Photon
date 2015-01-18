//
//  AppDelegate.m
//  Photon
//
//  Created by Philip Webster on 1/15/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, strong) PHBridgeSearching *bridgeSearch;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Create sdk instance
    self.phHueSDK = [[PHHueSDK alloc] init];
    [self.phHueSDK startUpSDK];
    [self.phHueSDK enableLogging:YES];
    [self.phHueSDK setBridgeToUseWithIpAddress:@"10.0.1.2" macAddress:@"00:17:88:18:b7:a2"];
    [self.phHueSDK startPushlinkAuthentication];
    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Heartbeat control

/**
 Starts the local heartbeat with a 10 second interval
 */
- (void)enableLocalHeartbeat {
    /***************************************************
     The heartbeat processing collects data from the bridge
     so now try to see if we have a bridge already connected
     *****************************************************/
    [self.phHueSDK enableLocalConnection];
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil) {
        // Enable heartbeat with interval of 10 seconds
        [self.phHueSDK enableLocalConnection];
    } else {
        // Automaticly start searching for bridges
        PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
        [notificationManager registerObject:self withSelector:@selector(authenticationSuccess) forNotification:PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION];
        [self.phHueSDK setBridgeToUseWithIpAddress:@"10.0.1.2" macAddress:@"00:17:88:18:b7:a2"];
        [self.phHueSDK startPushlinkAuthentication];
    }
}

/**
 Stops the local heartbeat
 */
- (void)disableLocalHeartbeat {
    [self.phHueSDK disableLocalConnection];
}

/**
 Notification receiver which is called when the pushlinking was successful
 */
- (void)authenticationSuccess {
    /***************************************************
     The notification PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION
     was received. We have confirmed the bridge.
     De-register for notifications and call
     pushLinkSuccess on the delegate
     *****************************************************/
    NSLog(@"authenticationSuccess");
    [self enableLocalHeartbeat];
}



@end
