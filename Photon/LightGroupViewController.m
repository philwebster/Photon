//
//  LightGroupViewController.m
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "LightGroupViewController.h"
#import "LightGroupCollectionViewCell.h"
#import <HueSDK_iOS/HueSDK.h>

@interface LightGroupViewController ()
@property (nonatomic, strong) PHHueSDK *phHueSDK;
@end

@implementation LightGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil hueSDK:(PHHueSDK *)hueSdk {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

//        // Make it a form on iPad
//        self.modalPresentationStyle = UIModalPresentationFormSheet;
        
        self.phHueSDK = hueSdk;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.lightGroupCollectionView registerNib:[UINib nibWithNibName:@"LightGroupCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"lightCell"];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return [[[PHBridgeResourcesReader readBridgeResourcesCache] groups] count];
    } else {
        return [[[PHBridgeResourcesReader readBridgeResourcesCache] lights] count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LightGroupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"lightCell" forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor redColor].CGColor;
    cell.layer.borderWidth = 1;
    if (indexPath.section == 0) {
        NSArray *groups = [[[PHBridgeResourcesReader readBridgeResourcesCache] groups] allValues];
        cell.cellLabel.text = [groups[indexPath.row] name];
        cell.group = groups[indexPath.row];
        cell.light = nil;
    } else {
        NSArray *lights = [[[PHBridgeResourcesReader readBridgeResourcesCache] lights] allValues];
        cell.cellLabel.text = [lights[indexPath.row] name];
        cell.light = lights[indexPath.row];
        cell.group = nil;
    }
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return UIEdgeInsetsMake(0, 0, 50, 0);
    } else {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width / 3 - 20, self.view.frame.size.height / 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
