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

@interface PNLightController : NSObject

@property NSArray *standardColors;
@property NSArray *naturalColors;
@property NSArray *ctNaturalColors;

@property (nonatomic) NSArray *lights;
@property (nonatomic) NSArray *groups;
@property (nonatomic) NSArray *scenes;

@property (nonatomic, assign) BOOL inDemoMode;

+ (id)singleton;
- (void)setNaturalColor:(NSNumber *)ct forResource:(PHBridgeResource *)resource;
- (void)setColor:(UIColor *)color forResource:(PHBridgeResource *)resource;
- (void)setBrightness:(NSNumber *)brightness forResource:(PHBridgeResource *)resource;
- (void)setResourceOff:(PHBridgeResource *)resource;
- (void)setStateWithDict:(NSDictionary *)stateDict;
- (void)setScene:(PHScene *)scene onGroup:(PHGroup *)group;
- (PHLight *)lightWithId:(NSString *)lightId;
- (NSNumber *)averageBrightnessForGroup:(PHGroup *)group;
- (NSArray *)lightsForGroup:(PHGroup *)group;

@end
