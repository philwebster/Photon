//
//  LightGroupViewController.m
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "LightGroupViewController.h"
#import "LightGroupCollectionViewCell.h"
#import "LightGroupCollectionReusableView.h"
#import "GroupListViewController.h"
#import "AppDelegate.h"
#import <HueSDK_iOS/HueSDK.h>

@interface LightGroupViewController ()
@property (nonatomic, strong) PHHueSDK *phHueSDK;
@property (nonatomic, strong) GroupListViewController *groupListVC;
@end

@implementation LightGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil hueSDK:(PHHueSDK *)hueSdk {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

//        // Make it a form on iPad
//        self.modalPresentationStyle = UIModalPresentationFormSheet;
        PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
        // Register for the local heartbeat notifications
        [notificationManager registerObject:self withSelector:@selector(receivedHeartbeat) forNotification:LOCAL_CONNECTION_NOTIFICATION];
        
        self.phHueSDK = hueSdk;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.lightGroupCollectionView registerNib:[UINib nibWithNibName:@"LightGroupCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"lightCell"];
    [self.lightGroupCollectionView registerClass:[LightGroupCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionHeader"];

    self.lightGroupCollectionView.backgroundColor = [UIColor whiteColor];

    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.view.frame.size.width, 50);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    UICollectionReusableView *reusableview = nil;

    if (kind == UICollectionElementKindSectionHeader) {
        LightGroupCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionHeader" forIndexPath:indexPath];
        if (indexPath.section == 0) {
            headerView.headerLabel.text = @"Groups";
        } else if (indexPath.section == 1) {
            headerView.headerLabel.text = @"Lights";
        } else if (indexPath.section == 2) {
            headerView.headerLabel.text = @"Scenes";
        }
        reusableview = headerView;
    }
    return reusableview;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return [[[PHBridgeResourcesReader readBridgeResourcesCache] groups] count] + 1;
    } else if (section == 1) {
        return [[[PHBridgeResourcesReader readBridgeResourcesCache] lights] count];
    } else if (section == 2) {
        return [[[PHBridgeResourcesReader readBridgeResourcesCache] scenes] count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LightGroupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"lightCell" forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor blackColor].CGColor;
    cell.layer.borderWidth = 1;

    if (indexPath.section == 0) {
        NSArray *groups = [[[PHBridgeResourcesReader readBridgeResourcesCache] groups] allValues];
        if (indexPath.row == groups.count) {
            cell.cellLabel.text = @"Edit groups";
        } else {
            cell.cellLabel.text = [groups[indexPath.row] name];
        }
    } else if (indexPath.section == 1) {
        NSArray *lights = [[[PHBridgeResourcesReader readBridgeResourcesCache] lights] allValues];
        cell.cellLabel.text = [lights[indexPath.row] name];
    } else if (indexPath.section == 2) {
        NSArray *scenes = [[[PHBridgeResourcesReader readBridgeResourcesCache] scenes] allValues];
        cell.cellLabel.text = [scenes[indexPath.row] name];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row + 1 == [collectionView numberOfItemsInSection:indexPath.section]) {
        self.groupListVC = [[GroupListViewController alloc] init];
        UINavigationController *navController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navigationController];
        [navController setNavigationBarHidden:NO animated:YES];
        [navController pushViewController:self.groupListVC animated:NO];
    }
}

- (void)receivedHeartbeat {
    NSLog(@"Got heartbeat, reloading data");
    // TODO: Be smarter about reloading data
    [self.lightGroupCollectionView reloadData];
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
