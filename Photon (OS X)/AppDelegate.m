//
//  AppDelegate.m
//  Photon (OS X)
//
//  Created by Philip Webster on 4/25/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "AppDelegate.h"
#import "PNLightController.h"
#import <HueSDK_OSX/HueSDK.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *offButton;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)offButtonPressed:(id)sender {
    NSLog(@"off button pressed");
}

@end
