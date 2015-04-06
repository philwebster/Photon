//
//  PNUtilities.m
//  Photon
//
//  Created by Philip Webster on 3/7/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNUtilities.h"

@implementation PNUtilities

+ (CGPoint)xyFromCT:(NSNumber *)temperature {
    // check temperature for nil/0 here
    CGPoint coord;
    int temp = 1000000 / [temperature intValue];
    if (1667 <= temp && temp <= 4000) {
    	coord.x = -0.26612239 * pow(10, 9) / pow(temp,3) - 0.2343580 * pow(10,6) / pow(temp,2) + 0.8776956 * pow(10,3) / temp + 0.17990;
    } else if (4000 < temp && temp <= 25000) {
    	coord.x = -3.0258469 * pow(10, 9) / pow(temp,3) + 2.1070379 * pow(10,6) / pow(temp,2) + 0.2226347 * pow(10,3) / temp + 0.240390;
    }
    if (1667 <= temp && temp <= 2222) {
    	coord.y = -1.1063814 * pow(coord.x,3) - 1.34811020 * pow(coord.x,2) + 2.18555832 * coord.x - 0.20219683;
    } else if (2222 < temp && temp <= 4000) {
    	coord.y = -0.9549476 * pow(coord.x,3) - 1.37418593 * pow(coord.x,2) + 2.09137015 * coord.x - 0.16748867;
    } else if (4000 < temp && temp <= 25000) {
    	coord.y = 3.0817580 * pow(coord.x,3) - 5.87338670 * pow(coord.x,2) + 3.75112997 * coord.x - 0.37001483;
    }
    return coord;
}

@end
