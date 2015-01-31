//
//  PTNLightController.h
//  Photon
//
//  Created by Philip Webster on 1/24/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <HueSDK_iOS/HueSDK.h>

@interface PTNLightController : NSObject

@property NSArray *standardColors;
@property NSArray *naturalColors;
@property NSArray *ctNaturalColors;

@property (nonatomic) NSArray *lights;
@property (nonatomic) NSArray *groups;
@property (nonatomic) NSArray *scenes;

- (void)setNaturalColor:(NSNumber *)ct forResource:(PHBridgeResource *)resource;
- (void)setColor:(UIColor *)color forResource:(PHBridgeResource *)resource;
- (void)setResourceOff:(PHBridgeResource *)resource;
- (void)setStateWithDict:(NSDictionary *)stateDict;
- (void)setScene:(PHScene *)scene onGroup:(PHGroup *)group;

@end
