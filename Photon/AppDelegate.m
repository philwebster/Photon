//
//  AppDelegate.m
//  Photon
//
//  Created by Philip Webster on 1/15/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "AppDelegate.h"
#import "SetupViewController.h"
#import "LightGroupViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) PHBridgeSearching *bridgeSearch;

@property (nonatomic, strong) UIAlertView *noConnectionAlert;
@property (nonatomic, strong) UIAlertView *noBridgeFoundAlert;
@property (nonatomic, strong) UIAlertView *authenticationFailedAlert;

@property (nonatomic, strong) SetupViewController *setupVC;
@property (nonatomic, strong) LightGroupViewController *lightVC;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Create sdk instance
    self.phHueSDK = [[PHHueSDK alloc] init];
    [self.phHueSDK startUpSDK];
//    [self.phHueSDK enableLogging:YES];
    
    self.lightVC = [[LightGroupViewController alloc] initWithNibName:@"LightGroupViewController" bundle:[NSBundle mainBundle] hueSDK:self.phHueSDK];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.lightVC];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    
    /***************************************************
     The SDK will send the following notifications in response to events:
     
     - LOCAL_CONNECTION_NOTIFICATION
     This notification will notify that the bridge heartbeat occurred and the bridge resources cache data has been updated
     
     - NO_LOCAL_CONNECTION_NOTIFICATION
     This notification will notify that there is no connection with the bridge
     
     - NO_LOCAL_AUTHENTICATION_NOTIFICATION
     This notification will notify that there is no authentication against the bridge
     *****************************************************/
    
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(notAuthenticated) forNotification:NO_LOCAL_AUTHENTICATION_NOTIFICATION];
    
    /***************************************************
     The local heartbeat is a regular timer event in the SDK. Once enabled the SDK regular collects the current state of resources managed
     by the bridge into the Bridge Resources Cache
     *****************************************************/
    
    [self enableLocalHeartbeat];

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


/**
 Notification receiver for successful local connection
 */
- (void)localConnection {
    // Check current connection state
    [self checkConnectionState];
}

/**
 Notification receiver for failed local connection
 */
- (void)noLocalConnection {
    // Check current connection state
    [self checkConnectionState];
}

/**
 Notification receiver for failed local authentication
 */
- (void)notAuthenticated {
    /***************************************************
     We are not authenticated so we start the authentication process
     *****************************************************/
    
    // Remove no connection alert
    if (self.noConnectionAlert != nil) {
        [self.noConnectionAlert dismissWithClickedButtonIndex:[self.noConnectionAlert cancelButtonIndex] animated:YES];
        self.noConnectionAlert = nil;
    }
    
    /***************************************************
     doAuthentication will start the push linking
     *****************************************************/
    
    // Start local authenticion process
    [self performSelector:@selector(doAuthentication) withObject:nil afterDelay:0.5];
}

/**
 Checks if we are currently connected to the bridge locally and if not, it will show an error when the error is not already shown.
 */
- (void)checkConnectionState {
    if (!self.phHueSDK.localConnected) {
        // No connection at all, show connection popup
        if (self.noConnectionAlert == nil) {
            [self showNoConnectionDialog];
        }
        
    } else {
        // One of the connections is made, remove popups and loading views
        if (self.noConnectionAlert != nil) {
            [self.noConnectionAlert dismissWithClickedButtonIndex:[self.noConnectionAlert cancelButtonIndex] animated:YES];
            self.noConnectionAlert = nil;
        }
    }
}

/**
 Shows the first no connection alert with more connection options
 */
- (void)showNoConnectionDialog {
    
    self.noConnectionAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No connection", @"No connection alert title")
                                                        message:NSLocalizedString(@"Connection to bridge is lost", @"No Connection alert message")
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Reconnect", @"No connection alert reconnect button"), NSLocalizedString(@"Find new bridge", @"No connection find new bridge button"),NSLocalizedString(@"Cancel", @"No connection cancel button"), nil];
    self.noConnectionAlert.tag = 1;
    [self.noConnectionAlert show];
    
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
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil) {
        // Enable heartbeat with interval of 10 seconds
        [self.phHueSDK enableLocalConnection];
    } else {
        // Automatically start searching for bridges
        self.setupVC = [[SetupViewController alloc] initWithNibName:@"SetupViewController" bundle:[NSBundle mainBundle] hueSDK:self.phHueSDK delegate:self];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.setupVC];
        [navController setNavigationBarHidden:YES animated:NO];
//        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self.navigationController presentViewController:navController animated:NO completion:nil];

        [self searchForBridgeLocal];
    }
}

/**
 Stops the local heartbeat
 */
- (void)disableLocalHeartbeat {
    [self.phHueSDK disableLocalConnection];
}

#pragma mark - Bridge searching and selection

/**
 Search for bridges using UPnP and portal discovery, shows results to user or gives error when none found.
 */
- (void)searchForBridgeLocal {
    // Stop heartbeats
    [self disableLocalHeartbeat];
    
    // Show search screen
    // TODO: animate base station circle
    /***************************************************
     A bridge search is started using UPnP to find local bridges
     *****************************************************/
    
    // Start search
    self.bridgeSearch = [[PHBridgeSearching alloc] initWithUpnpSearch:YES andPortalSearch:YES andIpAdressSearch:YES];
    [self.bridgeSearch startSearchWithCompletionHandler:^(NSDictionary *bridgesFound) {
        /***************************************************
         The search is complete, check whether we found a bridge
         *****************************************************/
        bridgesFound = @{@"00:17:88:18:b7:xx":@"10.0.1.2",@"00:17:88:18:b7:yy":@"10.0.1.2", @"00:17:88:18:b7:a2": @"10.0.1.2"};
        
        // Check for results
        if (bridgesFound.count == 1) {
            NSArray *sortedKeys = [bridgesFound.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            /***************************************************
             The choice of bridge to use is made, store the mac
             and ip address for this bridge
             *****************************************************/
            
            // Get mac address and ip address of selected bridge
            NSString *mac = [sortedKeys objectAtIndex:0];
            NSString *ip = [bridgesFound objectForKey:mac];
            
            // Inform delegate
            [self bridgeSelectedWithIpAddress:ip andMacAddress:mac];

        } else if (bridgesFound.count > 1) {
            [self.setupVC setMultipleBridgesFound:bridgesFound];
        } else {
            /***************************************************
             No bridge was found was found. Tell the user and offer to retry.
             *****************************************************/
            
            self.noBridgeFoundAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No bridges", @"No bridge found alert title")
                                                                 message:NSLocalizedString(@"Could not find bridge", @"No bridge found alert message")
                                                                delegate:self
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"Retry", @"No bridge found alert retry button"),NSLocalizedString(@"Cancel", @"No bridge found alert cancel button"), nil];
            self.noBridgeFoundAlert.tag = 1;
            [self.noBridgeFoundAlert show];
        }
    }];
}

/**
 Delegate method for PHbridgeSelectionViewController which is invoked when a bridge is selected
 */
- (void)bridgeSelectedWithIpAddress:(NSString *)ipAddress andMacAddress:(NSString *)macAddress {
    /***************************************************
     Set the username, ipaddress and mac address,
     as the bridge properties that the SDK framework will use
     *****************************************************/
    
    [self.phHueSDK setBridgeToUseWithIpAddress:ipAddress macAddress:macAddress];
    
    /***************************************************
     Setting the hearbeat running will cause the SDK
     to regularly update the cache with the status of the
     bridge resources
     *****************************************************/
    
    // Start local heartbeat again
    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
}

#pragma mark - Bridge authentication

/**
 Start the local authentication process
 */
- (void)doAuthentication {
    [self disableLocalHeartbeat];
    [self.setupVC startPushLinking];
}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was successfull
 */
- (void)pushlinkSuccess {
    /***************************************************
     Push linking succeeded we are authenticated against
     the chosen bridge.
     *****************************************************/
    
    [self.lightVC.lightGroupCollectionView reloadData];
    
    // Remove pushlink view controller
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    self.setupVC = nil;
    
    // Start local heartbeat
    NSLog(@"push link success");
    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was not successfull
 */

- (void)pushlinkFailed:(PHError *)error {
    // Check which error occured
    if (error.code == PUSHLINK_NO_CONNECTION) {
        // No local connection to bridge
        [self noLocalConnection];
        
        // Start local heartbeat (to see when connection comes back)
        [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
    }
    else {
        // Bridge button not pressed in time
        self.authenticationFailedAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Authentication failed", @"Authentication failed alert title")
                                                                    message:NSLocalizedString(@"Make sure you press the button within 30 seconds", @"Authentication failed alert message")
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"Retry", @"Authentication failed alert retry button"), NSLocalizedString(@"Cancel", @"Authentication failed cancel button"), nil];
        [self.authenticationFailedAlert show];
    }
}

#pragma mark - Alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.noConnectionAlert && alertView.tag == 1) {
        // This is a no connection alert with option to reconnect or more options
        self.noConnectionAlert = nil;
        
        if (buttonIndex == 0) {
            // Retry, just wait for the heartbeat to finish
        }
        else if (buttonIndex == 1) {
            // Find new bridge button
            [self searchForBridgeLocal];
        }
        else if (buttonIndex == 2) {
            // Cancel and disable local heartbeat unit started manually again
            [self disableLocalHeartbeat];
        }
    }
    else if (alertView == self.noBridgeFoundAlert && alertView.tag == 1) {
        // This is the alert which is shown when no bridges are found locally
        self.noBridgeFoundAlert = nil;
        
        if (buttonIndex == 0) {
            // Retry
            [self searchForBridgeLocal];
        } else if (buttonIndex == 1) {
            // Cancel and disable local heartbeat unit started manually again
            [self disableLocalHeartbeat];
        }
    }
    else if (alertView == self.authenticationFailedAlert) {
        // This is the alert which is shown when local pushlinking authentication has failed
        self.authenticationFailedAlert = nil;
        
        if (buttonIndex == 0) {
            // Retry authentication
            [self doAuthentication];
        } else if (buttonIndex == 1) {
            // Remove connecting loading message
//            [self removeLoadingView];
            // Cancel authentication and disable local heartbeat unit started manually again
            [self disableLocalHeartbeat];
        }
    }
}



@end
