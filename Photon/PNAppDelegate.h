//
//  PTNAppDelegate.h
//  Photon
//
//  Created by Philip Webster on 1/15/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HueSDK_iOS/HueSDK.h>
#import "SetupViewController.h"

@interface PNAppDelegate : UIResponder <UIApplicationDelegate, BridgeSetupDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) PHHueSDK *phHueSDK;

- (void)searchForBridgeLocal;
- (void)bridgeSelectedWithIpAddress:(NSString *)ipAddress andMacAddress:(NSString *)macAddress;
- (void)doSetupProcess;
- (void)cancelBridgeSearch;

@end

