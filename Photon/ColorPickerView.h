//
//  ColorPickerView.h
//  Photon
//
//  Created by Philip Webster on 1/20/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHBridgeResource;

// TODO: Define color picker delegate

@interface ColorPickerView : UIView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UICollectionView *colorCollectionView;
@property UIButton *cancelButton;

// TODO: Color picker should return a color and not do the setting of a color, so it really shouldn't know about PHBridgeResource
@property PHBridgeResource *lightResource;

//- (id)initWithFrame:(CGRect)frame lightResource:(PHBridgeResource *)resource;

@end
