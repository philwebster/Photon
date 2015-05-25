//
//  PNResourceCVItem.m
//  Photon
//
//  Created by Philip Webster on 5/24/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNResourceCVItem.h"
#import "PNResourceCVCellView.h"

@interface PNResourceCVItem ()

@end

@implementation PNResourceCVItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)setSelected:(BOOL)flag
{
    [super setSelected:flag];
    [(PNResourceCVCellView *)self.view setSelected:flag];
    [(PNResourceCVCellView *)self.view setNeedsDisplay:YES];
}

@end
