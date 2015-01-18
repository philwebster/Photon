//
//  LightGroupCollectionViewCell.h
//  Photon
//
//  Created by Philip Webster on 1/17/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HueSDK_iOS/HueSDK.h>

@interface LightGroupCollectionViewCell : UICollectionViewCell

@property PHGroup *group;
@property PHLight *light;

- (void)setCellName:(NSString *)cellName;

@end
