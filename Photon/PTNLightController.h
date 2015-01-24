//
//  PTNLightController.h
//  Photon
//
//  Created by Philip Webster on 1/24/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HueSDK_iOS/HueSDK.h>

@interface PTNLightController : NSObject

- (void)setNaturalColor:(NSNumber *)ct forResource:(PHBridgeResource *)resource;
- (void)setColor:(UIColor *)color forResource:(PHBridgeResource *)resource;
- (void)setResourceOff:(PHBridgeResource *)resource;

@end
