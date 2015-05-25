//
//  PNResourceCVCellView.m
//  Photon
//
//  Created by Philip Webster on 5/24/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNResourceCVCellView.h"

@implementation PNResourceCVCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (self.selected) {
        [[NSColor blueColor] set];
        NSRectFill([self bounds]);
    }

    // Drawing code here.
}

@end
