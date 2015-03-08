//
//  UIColor+PNUtilities.m
//  Photon
//
//  Created by Philip Webster on 2/10/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "UIColor+PNUtilities.h"

@implementation UIColor (PNUtilities)

+(NSNumber *)tempFromColor:(UIColor *)color {
    if (!color) {
        return nil;
    }
    NSArray *naturalColors = @[ [UIColor colorWithHue:0.123 saturation:0.665 brightness:0.996 alpha:1.000],
                                [UIColor colorWithHue:0.132 saturation:0.227 brightness:1.000 alpha:1.000],
                                [UIColor colorWithHue:0.167 saturation:0.012 brightness:1.000 alpha:1.000],
                                [UIColor colorWithHue:0.549 saturation:0.200 brightness:1.000 alpha:1.000],
                                [UIColor colorWithHue:0.540 saturation:0.409 brightness:0.922 alpha:1.000]];
    NSArray *ctNaturalColors = @[@500, @413, @326, @240, @153];
    NSUInteger index = [naturalColors indexOfObject:color];
//    NSLog(@"Returning index: %lu for color: %@", (unsigned long)index, color);
    return ctNaturalColors[index];
}

@end
