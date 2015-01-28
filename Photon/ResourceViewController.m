//
//  LightGroupViewController.m
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "ResourceViewController.h"
#import "ResourceCollectionViewCell.h"
#import "GroupListViewController.h"
#import "PTNColorPickerView.h"
#import "PTNAppDelegate.h"
#import <HueSDK_iOS/HueSDK.h>

@interface ResourceViewController ()
@property (nonatomic, strong) PHHueSDK *phHueSDK;
@property (nonatomic, strong) GroupListViewController *groupListVC;
@property (nonatomic, strong) UILongPressGestureRecognizer *recognizer;
@property (nonatomic, strong) NSMutableDictionary *fakeGroups;
@property (nonatomic, strong) PHBridgeResource *selectedResource;
@property (weak, nonatomic) IBOutlet PTNColorPickerView *quickPickView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *colorTapRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *groupTapRecognizer;
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
                
        [self.lightGroupCollectionView registerClass:[ResourceCollectionViewCell class] forCellWithReuseIdentifier:@"lightCell"];
//        [self.lightGroupCollectionView registerClass:[ResourceCollectionHeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionHeader"];
        [self.lightGroupCollectionView registerNib:[UINib nibWithNibName:@"ResourceCollectionHeaderReusableView" bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionHeader"];
        
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
        if (indexPath.section == 0) {
            headerLabel.text = @"Groups";
        } else if (indexPath.section == 1) {
            headerLabel.text = @"Lights";
        } else if (indexPath.section == 2) {
            headerLabel.text = @"Scenes";
        }
        reusableview = headerView;
    }
    return reusableview;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    BOOL useFakeGroups = ((PTNAppDelegate *)[[UIApplication sharedApplication] delegate]).inDemoMode;
    if (section == 0) {
        return useFakeGroups ? [_fakeGroups count] + 1 : [[[PHBridgeResourcesReader readBridgeResourcesCache] groups] count] + 1;
    } else if (section == 1) {
        return [[[PHBridgeResourcesReader readBridgeResourcesCache] lights] count];
    } else if (section == 2) {
        return [[[PHBridgeResourcesReader readBridgeResourcesCache] scenes] count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ResourceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"lightCell" forIndexPath:indexPath];

    if (indexPath.section == 0) {
        BOOL useFakeGroups = ((PTNAppDelegate *)[[UIApplication sharedApplication] delegate]).inDemoMode;
        NSArray *groups = useFakeGroups ? [_fakeGroups allValues] : [[[PHBridgeResourcesReader readBridgeResourcesCache] groups] allValues];
        // TODO: Add a default All group if user doesn't already have one
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

- (PHBridgeResource *)bridgeResourceForIndexPath:(NSIndexPath *)indexPath {
    NSArray *group;
    if (indexPath.section == 0) {
        BOOL useFakeGroups = ((PTNAppDelegate *)[[UIApplication sharedApplication] delegate]).inDemoMode;
        group = useFakeGroups ? [_fakeGroups allValues] : [[[PHBridgeResourcesReader readBridgeResourcesCache] groups] allValues];
        if (indexPath.row >= group.count) {
            // selected edit groups
            NSLog(@"returning nil for bridge resource");
            return nil;
        }
    } else if (indexPath.section == 1) {
        group = [[[PHBridgeResourcesReader readBridgeResourcesCache] lights] allValues];
    } else if (indexPath.section == 2) {
        group = [[[PHBridgeResourcesReader readBridgeResourcesCache] scenes] allValues];
    }
    return group[indexPath.row];
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
    UINavigationController *navController = [(PTNAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController];
    if (indexPath.section == 0) {
        if (indexPath.row + 1 == [collectionView numberOfItemsInSection:indexPath.section]) {
            self.groupListVC = [[GroupListViewController alloc] init];
            [navController setNavigationBarHidden:NO];
            [navController pushViewController:self.groupListVC animated:NO];
        } else {
            NSArray *groups = [[[PHBridgeResourcesReader readBridgeResourcesCache] groups] allValues];
            _quickPickView.lightResource = groups[indexPath.row];
            _quickPickView.hidden = NO;
        }
    } else if (indexPath.section == 1) {
        NSArray *lights = [[[PHBridgeResourcesReader readBridgeResourcesCache] lights] allValues];
        _quickPickView.lightResource = lights[indexPath.row];
        _quickPickView.hidden = NO;
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    CGPoint p = [recognizer locationInView:self.lightGroupCollectionView];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [self.lightGroupCollectionView indexPathForItemAtPoint:p];
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
        NSLog(@"gestureRecognizer.state = %ld", recognizer.state);
        
    }
}

- (IBAction)handleGroupTap:(UITapGestureRecognizer *)sender {
    CGPoint p = [sender locationInView:self.lightGroupCollectionView];
    NSIndexPath *indexPath = [self.lightGroupCollectionView indexPathForItemAtPoint:p];

    if (indexPath.section == 0) {
        if (indexPath.row + 1 == [self.lightGroupCollectionView numberOfItemsInSection:indexPath.section]) {
            UINavigationController *navController = [(PTNAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController];
            self.groupListVC = [[GroupListViewController alloc] init];
            [navController setNavigationBarHidden:NO];
            [navController pushViewController:self.groupListVC animated:NO];
            return;
        }
    }
    
    _selectedResource = [self bridgeResourceForIndexPath:indexPath];
    _quickPickView.hidden = NO;
    [self.view bringSubviewToFront:_quickPickView];
}

- (IBAction)handleColorTap:(UITapGestureRecognizer *)sender {
    CGPoint p = [sender locationInView:self.lightGroupCollectionView];

    _quickPickView.lightResource = _selectedResource;
    NSIndexPath *indexPath = [_quickPickView.colorCollectionView indexPathForItemAtPoint:p];
    [_quickPickView collectionView:_quickPickView.colorCollectionView didSelectItemAtIndexPath:indexPath];
    NSLog(@"color tap handled");
    _quickPickView.hidden = YES;
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
