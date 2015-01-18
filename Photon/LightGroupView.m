//
//  LightGroupView.m
//  Photon
//
//  Created by Philip Webster on 1/16/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "LightGroupView.h"

@interface LightGroupView ()

@property NSMutableArray *groups;
@property NSMutableArray *lights;

@end

@implementation LightGroupView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        _lightGroups = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:layout];
        _lightGroups.dataSource = self;
        _lightGroups.delegate = self;
        [_lightGroups registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"lightCell"];
        [self addSubview:_lightGroups];
        _lights = [NSMutableArray arrayWithArray:@[[UIColor yellowColor],
                                                   [UIColor greenColor],
                                                   [UIColor redColor],
                                                   [UIColor brownColor],
                                                   [UIColor orangeColor],
                                                   [UIColor purpleColor],
                                                   [UIColor lightGrayColor],
                                                   [UIColor lightTextColor],
                                                   [UIColor blueColor]]];
        _groups = [NSMutableArray arrayWithArray:@[[UIColor yellowColor],
                                                   [UIColor greenColor],
                                                   [UIColor redColor],
                                                   [UIColor brownColor],
                                                   [UIColor orangeColor],
                                                   [UIColor purpleColor],
                                                   [UIColor lightGrayColor],
                                                   [UIColor lightTextColor],
                                                   [UIColor blueColor]]];

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
    NSMutableArray *source = indexPath.section == 0 ? _groups : _lights;
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"lightCell" forIndexPath:indexPath];
    UIColor *color = source[indexPath.row];
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