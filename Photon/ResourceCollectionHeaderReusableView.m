//
//  LightGroupCollectionReusableView.m
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "ResourceCollectionHeaderReusableView.h"

@implementation ResourceCollectionHeaderReusableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.headerLabel = [UILabel new];
        self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.headerLabel];
    }
    return self;
}

- (void)layoutSubviews {
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_headerLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_headerLabel)]];
}

- (void)prepareForReuse {
    self.headerLabel.text = nil;
}

@end
