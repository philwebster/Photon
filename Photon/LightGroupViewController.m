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
#import "ColorPickerViewController.h"
#import "AppDelegate.h"
#import <HueSDK_iOS/HueSDK.h>

@interface LightGroupViewController ()
@property (nonatomic, strong) PHHueSDK *phHueSDK;
@property (nonatomic, strong) GroupListViewController *groupListVC;
@property (nonatomic, strong) ColorPickerViewController *colorPickerVC;
@property (nonatomic, strong) UILongPressGestureRecognizer *recognizer;
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
        
        _recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        _recognizer.minimumPressDuration = 0.1;
        _recognizer.delegate = self;
        [self.view addGestureRecognizer:_recognizer];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.lightGroupCollectionView registerNib:[UINib nibWithNibName:@"LightGroupCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"lightCell"];
    [self.lightGroupCollectionView registerClass:[LightGroupCollectionViewCell class] forCellWithReuseIdentifier:@"lightCell"];

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
    if (section == 0 || section == 1) {
        return UIEdgeInsetsMake(0, 0, 50, 0);
    } else {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width / 3, self.view.frame.size.height / 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UINavigationController *navController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navigationController];
    if (indexPath.section == 0) {
        if (indexPath.row + 1 == [collectionView numberOfItemsInSection:indexPath.section]) {
            self.groupListVC = [[GroupListViewController alloc] init];
            [navController setNavigationBarHidden:NO];
            [navController pushViewController:self.groupListVC animated:NO];
        } else {
            NSArray *groups = [[[PHBridgeResourcesReader readBridgeResourcesCache] groups] allValues];
            self.colorPickerVC = [[ColorPickerViewController alloc] initWithLightResource:groups[indexPath.row]];
            [navController setNavigationBarHidden:NO];
            [navController pushViewController:self.colorPickerVC animated:NO];
        }
    } else if (indexPath.section == 1) {
        NSArray *lights = [[[PHBridgeResourcesReader readBridgeResourcesCache] lights] allValues];
        self.colorPickerVC = [[ColorPickerViewController alloc] initWithLightResource:lights[indexPath.row]];
        [navController setNavigationBarHidden:NO];
        [navController pushViewController:self.colorPickerVC animated:NO];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    //    _lightView.hidden = NO;
    //    [self.view bringSubviewToFront:_lightView];
    CGPoint p = [recognizer locationInView:self.lightGroupCollectionView];
    
    NSIndexPath *indexPath = [self.lightGroupCollectionView indexPathForItemAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on view but not on a row");
    } else if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long press on view at row %ld", (long)indexPath.row);
        [self collectionView:_lightGroupCollectionView didSelectItemAtIndexPath:indexPath];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        //        NSIndexPath *path = [_lightView.lightGroups indexPathForItemAtPoint:p];
        
        //        LightGroupCollectionViewCell *c = (LightGroupCollectionViewCell *)[_lightView collectionView:_lightView.lightGroups cellForItemAtIndexPath:path];
                NSLog(@"long press ended");
        //        _lightView.hidden = YES;
        //        if (c.group) {
        //            [self setStateForGroup:c.group];
        //        }
    } else {
                NSLog(@"gestureRecognizer.state = %ld", recognizer.state);
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