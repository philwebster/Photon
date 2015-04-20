//
//  ResourceCollectionViewCell.m
//  Photon
//
//  Created by Philip Webster on 1/31/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "ResourceCollectionViewCell.h"

@implementation ResourceCollectionViewCell

- (void)prepareForReuse {
    self.plusImage.hidden = YES;
    self.resourceTitleLabel.text = @"";
}

@end
