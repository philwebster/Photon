//
//  LightGroupView.m
//  Photon
//
//  Created by Philip Webster on 1/16/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "LightGroupView.h"
#import <HueSDK_iOS/HueSDK.h>
#import "LightGroupCollectionViewCell.h"

@interface LightGroupView ()

@property NSArray *groups;
@property NSArray *lights;

@end

@implementation LightGroupView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        _lightGroups = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:layout];
        _lightGroups.dataSource = self;
        _lightGroups.delegate = self;
        [_lightGroups registerClass:[LightGroupCollectionViewCell class] forCellWithReuseIdentifier:@"lightCell"];
        [self addSubview:_lightGroups];
        
        // Get the cache
        PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
        // And now you can get any resource you want, for example:
        _lights = [cache.lights allValues];
        
        _groups = [cache.groups allValues];
        
//        _lights = [NSMutableArray arrayWithArray:@[[UIColor yellowColor],
//                                                   [UIColor greenColor],
//                                                   [UIColor redColor],
//                                                   [UIColor brownColor],
//                                                   [UIColor orangeColor],
//                                                   [UIColor purpleColor],
//                                                   [UIColor lightGrayColor],
//                                                   [UIColor lightTextColor],
//                                                   [UIColor blueColor]]];
//        _groups = [NSMutableArray arrayWithArray:@[[UIColor yellowColor],
//                                                   [UIColor greenColor],
//                                                   [UIColor redColor],
//                                                   [UIColor brownColor],
//                                                   [UIColor orangeColor],
//                                                   [UIColor purpleColor],
//                                                   [UIColor lightGrayColor],
//                                                   [UIColor lightTextColor],
//                                                   [UIColor blueColor]]];

    }
    return self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return [_groups count];
    } else {
        return [_lights count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LightGroupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"lightCell" forIndexPath:indexPath];

    if (indexPath.section == 0) {
        [cell setCellName:[_groups[indexPath.row] name]];
        [cell setGroup:_groups[indexPath.row]];
        cell.light = nil;
    } else {
        [cell setCellName:[_lights[indexPath.row] name]];
        [cell setLight:_lights[indexPath.row]];
        cell.group = nil;
    }
//    NSArray *source = indexPath.section == 0 ? _groups : _lights;
//    LightGroupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"lightCell" forIndexPath:indexPath];
    
    UIColor *color = [UIColor redColor];
    cell.backgroundColor = color;
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return UIEdgeInsetsMake(0, 0, 50, 0);
    } else {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

@end
