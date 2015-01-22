//
//  LightGroupCollectionViewCell.m
//  Photon
//
//  Created by Philip Webster on 1/17/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "ResourceCollectionViewCell.h"

@interface ResourceCollectionViewCell ()

@end

@implementation ResourceCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.cellLabel = [UILabel new];
        self.cellLabel.textAlignment = NSTextAlignmentCenter;
        
        self.cellLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.cellLabel];
    }
    return self;
}

- (void)layoutSubviews {
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_cellLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cellLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cellLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cellLabel)]];

}

- (void)prepareForReuse {
    _cellLabel.text = nil;
}


@end
