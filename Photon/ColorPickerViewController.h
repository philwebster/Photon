//
//  ColorPickerViewController.h
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LightGroupViewController.h"

@class PHBridgeResource;

@interface ColorPickerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, ViewControllerWithGestureRecognizerDelegate>

@property (strong, nonatomic) UICollectionView *colorCollectionView;

- (id)initWithLightResource:(PHBridgeResource *)resource;

@end
