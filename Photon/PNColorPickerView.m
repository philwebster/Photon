//
//  PTNColorPickerView.m
//  Photon
//
//  Created by Philip Webster on 1/20/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNColorPickerView.h"
#import "PNLightController.h"

@interface PNColorPickerView()

@property UICollectionViewFlowLayout *flowLayout;
@property PNLightController *lightController;

@end

@implementation PNColorPickerView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.colorCollectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:self.flowLayout];
        [self.colorCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"colorCell"];
        
        self.colorCollectionView.backgroundColor = [UIColor grayColor];
        
        self.colorCollectionView.delegate = self;
        self.colorCollectionView.dataSource = self;
        
        [self addSubview:self.colorCollectionView];
        [_colorCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_colorCollectionView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_colorCollectionView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_colorCollectionView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_colorCollectionView)]];

        self.cancelButton = [UIButton new];
        self.cancelButton.backgroundColor = [UIColor whiteColor];
        [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.cancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.cancelButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cancelButton];
        [self bringSubviewToFront:_cancelButton];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_cancelButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cancelButton)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_cancelButton]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cancelButton)]];
        
        self.lightController = [PNLightController new];
    }
    return self;
}

#pragma mark CollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(self.frame.size.width / 5, 100);
    } else if (indexPath.section == 1) {
        return CGSizeMake(self.frame.size.width, (self.frame.size.height - 200) / self.lightController.standardColors.count);
    } else if (indexPath.section == 2) {
        return CGSizeMake(self.frame.size.width / 2, 100);
    }
    return CGSizeMake(0, 0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark CollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.lightController.naturalColors.count;
    } else if (section == 1) {
        return self.lightController.standardColors.count;
    } else if (section == 2) {
        return 2;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"colorCell" forIndexPath:indexPath];
    UIColor *color;
    if (indexPath.section == 0) {
        color = self.lightController.naturalColors[indexPath.row];
    } else if (indexPath.section == 1) {
        color = self.lightController.standardColors[indexPath.row];
    } else if (indexPath.section == 2) {
        color = indexPath.row == 0 ? [UIColor grayColor] : [UIColor blackColor];
    }
    cell.backgroundColor = color;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIColor *color = [_colorCollectionView cellForItemAtIndexPath:indexPath].backgroundColor;
    if (indexPath.section == 0) {
        [self.lightController setNaturalColor:self.lightController.ctNaturalColors[indexPath.row] forResource:self.lightResource];
    } else if (indexPath.section == 1) {
        [self.lightController setColor:[_colorCollectionView cellForItemAtIndexPath:indexPath].backgroundColor forResource:self.lightResource];
    } else if (indexPath.section == 2) {
        if (color == [UIColor blackColor]) {
            [self.lightController setResourceOff:self.lightResource];
        }
    }
    self.hidden = YES;
}

- (void)dismissView {
    self.hidden = YES;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
