//
//  LightGroupViewController.m
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "ResourceViewController.h"
#import "GroupListViewController.h"
#import "SceneListViewController.h"
#import "PNColorPickerVC.h"
#import "PNColorPickerView.h"
#import "PNAppDelegate.h"
#import "PNLightController.h"
#import "ResourceCollectionViewCell.h"
#import <HueSDK_iOS/HueSDK.h>

@interface ResourceViewController ()
@property (nonatomic, strong) PHHueSDK *phHueSDK;
@property (nonatomic, strong) PNLightController *lightController;
@property (nonatomic, strong) GroupListViewController *groupListVC;
@property (nonatomic, strong) SceneListViewController *sceneListVC;
@property (nonatomic, strong) UILongPressGestureRecognizer *recognizer;
@property (nonatomic, strong) NSMutableDictionary *fakeGroups;
@property (nonatomic, strong) PHBridgeResource *selectedResource;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet PNColorPickerView *quickPickView;
@property (nonatomic, strong) PNColorPickerVC *colorPickerVC;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@end

@implementation ResourceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil hueSDK:(PHHueSDK *)hueSdk {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        // Make it a form on iPad
//        self.modalPresentationStyle = UIModalPresentationFormSheet;
        PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
        // Register for the local heartbeat notifications
        [notificationManager registerObject:self withSelector:@selector(receivedHeartbeat) forNotification:LOCAL_CONNECTION_NOTIFICATION];
        
        self.phHueSDK = hueSdk;
        
        _fakeGroups = [NSMutableDictionary new];
        for (int i = 0; i < 5; ++i) {
            PHGroup *group = [[PHGroup alloc] init];
            group.name = @"fake group 1";
            [_fakeGroups setObject:group forKey:[NSNumber numberWithInt:i]];
        }
        
        _recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        _recognizer.minimumPressDuration = 0.1;
        _recognizer.delegate = self;
        [self.view addGestureRecognizer:_recognizer];
        
        [self.lightGroupCollectionView registerNib:[UINib nibWithNibName:@"ResourceCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"resourceCell"];
        [self.lightGroupCollectionView registerNib:[UINib nibWithNibName:@"ResourceCollectionHeaderReusableView" bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionHeader"];
        
        self.lightController = [PNLightController singleton];
        self.colorPickerVC = [[PNColorPickerVC alloc] init];
    }
    return self;
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
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionHeader" forIndexPath:indexPath];
        UILabel *headerLabel = (UILabel *)[headerView viewWithTag:100];
        UIButton *headerEditButton = (UIButton *)[headerView viewWithTag:101];
        [headerEditButton removeTarget:nil
                                action:NULL
                      forControlEvents:UIControlEventAllEvents];
        if (indexPath.section == 0) {
            headerLabel.text = @"Groups";
            [headerEditButton addTarget:self action:@selector(editGroupsTapped) forControlEvents:UIControlEventTouchUpInside];
        } else if (indexPath.section == 1) {
            headerLabel.text = @"Lights";
            [headerEditButton addTarget:self action:@selector(editLightsTapped) forControlEvents:UIControlEventTouchUpInside];
        } else if (indexPath.section == 2) {
            headerLabel.text = @"Scenes";
            [headerEditButton addTarget:self action:@selector(editScenesTapped) forControlEvents:UIControlEventTouchUpInside];
        }
        reusableview = headerView;
    }
    return reusableview;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.lightController.groups count];
    } else if (section == 1) {
        return [self.lightController.lights count];
    } else if (section == 2) {
        return [self.lightController.scenes count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ResourceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"resourceCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        NSArray *groups = self.lightController.groups;
        // TODO: Add a default All group if user doesn't already have one
        cell.resourceTitleLabel.text = [groups[indexPath.row] name];
    } else if (indexPath.section == 1) {
        NSArray *lights = self.lightController.lights;
        cell.resourceTitleLabel.text = [lights[indexPath.row] name];
    } else if (indexPath.section == 2) {
        NSArray *scenes = self.lightController.scenes;
        cell.resourceTitleLabel.text = [scenes[indexPath.row] name];
    }
    return cell;
}

- (PHBridgeResource *)bridgeResourceForIndexPath:(NSIndexPath *)indexPath {
    NSArray *resources;
    if (indexPath.section == 0) {
        resources = self.lightController.groups;
    } else if (indexPath.section == 1) {
        resources = self.lightController.lights;
    } else if (indexPath.section == 2) {
        resources = self.lightController.scenes;
    }
    return resources[indexPath.row];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width / 3, 100);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UINavigationController *navController = [(PNAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController];
        [navController setNavigationBarHidden:NO];
        self.colorPickerVC.resource = self.lightController.groups[indexPath.row];
        [navController pushViewController:self.colorPickerVC animated:YES];
    } else if (indexPath.section == 1) {
        NSArray *lights = self.lightController.lights;
        _quickPickView.lightResource = lights[indexPath.row];
        _quickPickView.hidden = NO;
    } else if (indexPath.section == 2) {
        NSArray *scenes = self.lightController.scenes;
        [self.lightController setScene:scenes[indexPath.row] onGroup:nil];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    CGPoint p = [recognizer locationInView:self.lightGroupCollectionView];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [self.lightGroupCollectionView indexPathForItemAtPoint:p];
        if (!indexPath) {
            return;
        }
        _selectedResource = [self bridgeResourceForIndexPath:indexPath];
        [self.view bringSubviewToFront:_quickPickView];
        _quickPickView.hidden = NO;
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        _quickPickView.lightResource = _selectedResource;

        if (!CGRectContainsPoint(_quickPickView.cancelButton.frame, p)) {
            NSIndexPath *indexPath = [_quickPickView.colorCollectionView indexPathForItemAtPoint:p];
            [_quickPickView collectionView:_quickPickView.colorCollectionView didSelectItemAtIndexPath:indexPath];
        }
        NSLog(@"long press ended");
        _quickPickView.hidden = YES;
    } else {
//        NSLog(@"gestureRecognizer.state = %ld", recognizer.state);
        
    }
}

- (void)receivedHeartbeat {
    NSLog(@"Got heartbeat, reloading data");
    // TODO: Be smarter about reloading data
    [self.lightGroupCollectionView reloadData];
}

- (IBAction)settingsButtonPressed:(id)sender {
    NSLog(@"Settings pressed");
}

- (void)editGroupsTapped {
    UINavigationController *navController = [(PNAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController];
    self.groupListVC = [[GroupListViewController alloc] init];
    [navController setNavigationBarHidden:NO];
    [navController pushViewController:self.groupListVC animated:YES];
}

- (void)editLightsTapped {
    NSLog(@"edit lights tapped");
}

- (void)editScenesTapped {
    UINavigationController *navController = [(PNAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController];
    self.sceneListVC = [[SceneListViewController alloc] init];
    [navController setNavigationBarHidden:NO];
    [navController pushViewController:self.sceneListVC animated:YES];
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
