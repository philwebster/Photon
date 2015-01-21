//
//  LightGroupViewController.h
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHHueSDK;

@protocol ViewControllerWithGestureRecognizerDelegate

- (void)viewControllerGestureRecognizerEvent:(UILongPressGestureRecognizer *)gestureRecognizer;

@end


@interface LightGroupViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil hueSDK:(PHHueSDK *)hueSdk;

@property (strong, nonatomic) IBOutlet UICollectionView *lightGroupCollectionView;

@end
