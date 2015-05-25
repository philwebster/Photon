//
//  PNButton.m
//  Photon
//
//  Created by Philip Webster on 5/25/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNButton.h"

@implementation PNButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setHighlighted:(BOOL)highlighted {
    self.layer.cornerRadius = 8;
    if (highlighted) {
        [self setBackgroundColor:[UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1]];
    } else {
        [self setBackgroundColor:[UIColor clearColor]];
    }
}

@end
