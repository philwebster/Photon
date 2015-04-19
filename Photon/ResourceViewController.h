//
//  LightGroupViewController.h
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNColorPickerVC.h"

@interface ResourceViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, colorPickerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *lightGroupCollectionView;

@end
