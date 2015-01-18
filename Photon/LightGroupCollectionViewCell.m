//
//  LightGroupCollectionViewCell.m
//  Photon
//
//  Created by Philip Webster on 1/17/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "LightGroupCollectionViewCell.h"

@interface LightGroupCollectionViewCell ()

@property UILabel *cellLabel;

@end

@implementation LightGroupCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.cellLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.autoresizesSubviews = YES;
        self.cellLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                       UIViewAutoresizingFlexibleHeight);
//        self.label.font = [UIFont boldSystemFontOfSize:42];
        self.cellLabel.textAlignment = NSTextAlignmentCenter;
        self.cellLabel.adjustsFontSizeToFitWidth = YES;
        
        [self addSubview:self.cellLabel];
    }
    return self;
}

- (void)setCellName:(NSString *)cellName {
    self.cellLabel.text = cellName;
}

@end
