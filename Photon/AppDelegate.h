//
//  AppDelegate.h
//  Photon
//
//  Created by Philip Webster on 1/15/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HueSDK_iOS/HueSDK.h>
#import "SetupViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, BridgeSetupDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) PHHueSDK *phHueSDK;
@property (nonatomic, assign) BOOL inDemoMode;

- (void)searchForBridgeLocal;
- (void)bridgeSelectedWithIpAddress:(NSString *)ipAddress andMacAddress:(NSString *)macAddress;

@end

