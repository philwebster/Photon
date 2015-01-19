//
//  LightGroupCollectionReusableView.m
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "LightGroupCollectionReusableView.h"

@implementation LightGroupCollectionReusableView

- (void)layoutSubviews {
    self.headerLabel = [UILabel new];
    self.headerLabel.text = @"Hello";
    self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.headerLabel];
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_headerLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_headerLabel)]];
}

@end
