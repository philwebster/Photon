//
//  LightGroupViewController.m
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "ResourceViewController.h"
#import "SceneListViewController.h"
#import "PNAppDelegate.h"
#import "PNLightController.h"
#import "ResourceCollectionViewCell.h"
#import "PNResourceSettingVC.h"
#import "PNGroupListVC.h"
#import "PNSettingsVC.h"
#import <HueSDK_iOS/HueSDK.h>

@interface ResourceViewController ()
@property (nonatomic, strong) PNLightController *lightController;
@property (nonatomic, strong) PNGroupListVC *groupListVC;
@property (nonatomic, strong) SceneListViewController *sceneListVC;
@property (nonatomic, strong) UILongPressGestureRecognizer *recognizer;
@property (nonatomic, strong) NSMutableDictionary *fakeGroups;
@property (nonatomic, strong) PHBridgeResource *selectedResource;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (nonatomic, strong) PNColorPickerVC *colorPickerVC;
@property (nonatomic, strong) PNResourceSettingVC *resourceSettingVC;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) BOOL pickingColor;
@end

@implementation ResourceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        // Make it a form on iPad
//        self.modalPresentationStyle = UIModalPresentationFormSheet;
        PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
        // Register for the local heartbeat notifications
        [notificationManager registerObject:self withSelector:@selector(receivedHeartbeat) forNotification:LOCAL_CONNECTION_NOTIFICATION];
        
        self.pickingColor = NO;
        
        // TODO: remove this
        _fakeGroups = [NSMutableDictionary new];
        for (int i = 0; i < 5; ++i) {
            PHGroup *group = [[PHGroup alloc] init];
            group.name = @"fake group 1";
            [_fakeGroups setObject:group forKey:[NSNumber numberWithInt:i]];
        }
        
        _recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        _recognizer.minimumPressDuration = 0.2;
        _recognizer.delegate = self;
        [self.view addGestureRecognizer:_recognizer];
        
        [self.lightGroupCollectionView registerNib:[UINib nibWithNibName:@"ResourceCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"resourceCell"];
        [self.lightGroupCollectionView registerNib:[UINib nibWithNibName:@"ResourceCollectionHeaderReusableView" bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionHeader"];
        self.lightGroupCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 45, 0);
        self.lightGroupCollectionView.layer.cornerRadius = 4;
        
        self.lightController = [PNLightController singleton];
        self.colorPickerVC = [[PNColorPickerVC alloc] init];
        self.colorPickerVC.colorDelegate = self;
        
        self.resourceSettingVC = [[PNResourceSettingVC alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
}

- (void)viewWillLayoutSubviews {
    self.resourceSettingVC.view.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.view.frame.size.width, 50);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
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
        if (indexPath.row == resources.count) {
            return nil;
        }
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
    self.recognizer.enabled = NO;
    if (indexPath.section == 0) {
        self.resourceSettingVC.resource = self.lightController.groups[indexPath.row];

        self.resourceSettingVC.view.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
        [UIView animateWithDuration:0.1
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.resourceSettingVC.view.frame = self.view.frame;
                         }
                         completion:^(BOOL finished){
                         }];
        
        [self.view addSubview:self.resourceSettingVC.view];
        [self addChildViewController:self.resourceSettingVC];
        [self didMoveToParentViewController:self.resourceSettingVC];
    } else if (indexPath.section == 1) {
        self.resourceSettingVC.resource = self.lightController.lights[indexPath.row];
        [self.view addSubview:self.resourceSettingVC.view];
        [self addChildViewController:self.resourceSettingVC];
        [self didMoveToParentViewController:self.resourceSettingVC];
    } else if (indexPath.section == 2) {
        NSArray *scenes = self.lightController.scenes;
        [self.lightController setScene:scenes[indexPath.row] onGroup:nil];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {

    if (recognizer.state == UIGestureRecognizerStateEnded) {
//        NSLog(@"long press ended");
        [self.colorPickerVC handleLongPress:recognizer];
        self.pickingColor = NO;
        return;
    }
    
    if (self.pickingColor) {
        [self.colorPickerVC handleLongPress:recognizer];
        return;
    }

    CGPoint p = [recognizer locationInView:self.lightGroupCollectionView];
    if (recognizer.state == UIGestureRecognizerStateBegan && self.isFirstResponder) {
        NSIndexPath *indexPath = [self.lightGroupCollectionView indexPathForItemAtPoint:p];
        if (!indexPath) {
            return;
        }
        _selectedResource = [self bridgeResourceForIndexPath:indexPath];
        if (!_selectedResource) {
            return;
        }
        self.colorPickerVC.resource = _selectedResource;
        [self addChildViewController:self.colorPickerVC];
        [self.view addSubview:self.colorPickerVC.view];
        self.pickingColor = YES;
        [self resignFirstResponder];
    } else {
//        NSLog(@"gestureRecognizer.state = %ld", recognizer.state);
    }
}

- (void)receivedHeartbeat {
    // TODO: Be smarter about reloading data
    [self.lightGroupCollectionView reloadData];
}

- (IBAction)settingsButtonPressed:(id)sender {
    PNSettingsVC *settingsVC = [[PNSettingsVC alloc] init];
    settingsVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:settingsVC animated:YES completion:nil];
}

- (void)editGroupsTapped {
    UINavigationController *navController = [(PNAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController];
    self.groupListVC = [[PNGroupListVC alloc] init];
    [navController pushViewController:self.groupListVC animated:YES];
}

- (void)addGroupTapped {
    UINavigationController *navController = [(PNAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController];
    self.groupListVC = [[PNGroupListVC alloc] init];
    [navController pushViewController:self.groupListVC animated:YES];
}

- (void)editLightsTapped {
    PNGroupListVC *lightList = [[PNGroupListVC alloc] initWithLights];
    [self.navigationController pushViewController:lightList animated:YES];
}

- (void)editScenesTapped {
    UINavigationController *navController = [(PNAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController];
    self.sceneListVC = [[SceneListViewController alloc] init];
    [navController setNavigationBarHidden:NO];
    [navController pushViewController:self.sceneListVC animated:YES];
}

- (void)dismissedColorPicker {
    self.recognizer.enabled = YES;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
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
