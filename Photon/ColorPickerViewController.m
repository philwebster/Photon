//
//  ColorPickerViewController.m
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "ColorPickerViewController.h"
#import <HueSDK_iOS/HueSDK.h>

#define MAX_HUE 65535

@interface ColorPickerViewController ()

@property NSMutableArray *colors;
@property NSMutableArray *naturalColors;
@property NSArray *ctNaturalColors;
@property UICollectionViewFlowLayout *flowLayout;
@property PHBridgeResource *lightResource;

@end

@implementation ColorPickerViewController

- (id)initWithLightResource:(PHBridgeResource *)resource {
    self = [super init];
    if (self) {
        self.lightResource = resource;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.colorCollectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:self.flowLayout];
    [self.colorCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"colorCell"];
    
    self.colorCollectionView.backgroundColor = [UIColor whiteColor];
    
    self.colorCollectionView.delegate = self;
    self.colorCollectionView.dataSource = self;
    
    [self.view addSubview:self.colorCollectionView];
    _naturalColors = [NSMutableArray arrayWithArray:@[
                                               [UIColor colorWithHue:0.123 saturation:0.665 brightness:0.996 alpha:1.000],
                                               [UIColor colorWithHue:0.132 saturation:0.227 brightness:1.000 alpha:1.000],
                                               [UIColor colorWithHue:0.167 saturation:0.012 brightness:1.000 alpha:1.000],
                                               [UIColor colorWithHue:0.549 saturation:0.200 brightness:1.000 alpha:1.000],
                                               [UIColor colorWithHue:0.540 saturation:0.409 brightness:0.922 alpha:1.000]]];
    _ctNaturalColors = @[@500, @413, @326, @240, @153];
    
    _colors = [NSMutableArray arrayWithArray:@[[UIColor blackColor],
                                               [UIColor colorWithHue:0.626 saturation:0.871 brightness:1.000 alpha:1.000],
                                               [UIColor colorWithHue:0.788 saturation:1.000 brightness:0.996 alpha:1.000],
                                               [UIColor colorWithHue:0.846 saturation:1.000 brightness:0.984 alpha:1.000],
                                               [UIColor colorWithHue:0.965 saturation:1.000 brightness:0.984 alpha:1.000],
                                               [UIColor colorWithHue:0.081 saturation:0.881 brightness:0.992 alpha:1.000],
                                               [UIColor colorWithHue:0.155 saturation:0.941 brightness:0.996 alpha:1.000],
                                               [UIColor colorWithHue:0.341 saturation:0.748 brightness:1.000 alpha:1.000],
                                               [UIColor colorWithHue:0.468 saturation:0.808 brightness:1.000 alpha:1.000]]];
    
//    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//    recognizer.minimumPressDuration = .1;
//    [recognizer setDelaysTouchesBegan:NO];
//    recognizer.delegate = self;
//    [self.view addGestureRecognizer:recognizer];

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
        return _naturalColors.count;
    } else if (section == 1) {
        return [_colors count];
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(self.view.frame.size.width / 5, 100);
    } else if (indexPath.section == 1) {
        return CGSizeMake(self.view.frame.size.width, (self.view.frame.size.height - (100 + self.topLayoutGuide.length)) / _colors.count);
    }
    return CGSizeMake(0, 0);
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"colorCell" forIndexPath:indexPath];
    UIColor *color;
    if (indexPath.section == 0) {
        color = _naturalColors[indexPath.row];
    } else if (indexPath.section == 1) {
        color = _colors[indexPath.row];
    }
    cell.backgroundColor = color;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self setNaturalColor:_ctNaturalColors[indexPath.row] forResource:self.lightResource];
    } else {
        UIColor *color = [_colorCollectionView cellForItemAtIndexPath:indexPath].backgroundColor;
        if (color == [UIColor blackColor]) {
            [self setResourceOff:self.lightResource];
        } else {
            [self setColor:[_colorCollectionView cellForItemAtIndexPath:indexPath].backgroundColor forResource:self.lightResource];
        }
    }
}

- (void)setNaturalColor:(NSNumber *)ct forResource:(PHBridgeResource *)resource {
    PHLightState *lightState = [[PHLightState alloc] init];
    [lightState setCt:ct];
    [lightState setOnBool:YES];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    if ([resource isKindOfClass:[PHLight class]]) {
        [bridgeSendAPI updateLightStateForId:resource.identifier withLightState:lightState completionHandler:nil];
    } else if ([resource isKindOfClass:[PHGroup class]]) {
        [bridgeSendAPI setLightStateForGroupWithId:resource.identifier lightState:lightState completionHandler:nil];
    }
}

- (void)setColor:(UIColor *)color forResource:(PHBridgeResource *)resource {

    PHLightState *lightState = [[PHLightState alloc] init];
    
    CGFloat hue, sat, brightness, alpha;
    [color getHue:&hue saturation:&sat brightness:&brightness alpha:&alpha];
    [lightState setHue:[NSNumber numberWithInt:hue * MAX_HUE]];
    [lightState setBrightness:[NSNumber numberWithInt:254]];
    [lightState setSaturation:[NSNumber numberWithInt:254]];
    [lightState setOnBool:YES];
    
    // Send lightstate to light
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    if ([resource isKindOfClass:[PHLight class]]) {
        [bridgeSendAPI updateLightStateForId:resource.identifier withLightState:lightState completionHandler:nil];
    } else if ([resource isKindOfClass:[PHGroup class]]) {
        [bridgeSendAPI setLightStateForGroupWithId:resource.identifier lightState:lightState completionHandler:nil];
    }
}

- (void)setResourceOff:(PHBridgeResource *)resource {
    PHLightState *lightState = [[PHLightState alloc] init];
    [lightState setOnBool:NO];

    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    if ([resource isKindOfClass:[PHLight class]]) {
        [bridgeSendAPI updateLightStateForId:resource.identifier withLightState:lightState completionHandler:nil];
    } else if ([resource isKindOfClass:[PHGroup class]]) {
        [bridgeSendAPI setLightStateForGroupWithId:resource.identifier lightState:lightState completionHandler:nil];
    }
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    CGPoint location = [[touches anyObject] locationInView:_colorCollectionView];
//    NSIndexPath *indexPath = [_colorCollectionView indexPathForItemAtPoint:location];
//    [self collectionView:_colorCollectionView didSelectItemAtIndexPath:indexPath];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"touches moved");
//}

- (void)handleLongPress:(UITapGestureRecognizer *)recognizer {

    //    _lightView.hidden = NO;
    //    [self.view bringSubviewToFront:_lightView];
    CGPoint p = [recognizer locationInView:self.colorCollectionView];
    
    NSIndexPath *indexPath = [self.colorCollectionView indexPathForItemAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on view but not on a row");
    } else if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long press on view at row %ld", (long)indexPath.row);
        //self.initialTapColor = _colors[indexPath.row];
        //        _lightView.hidden = NO;
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        //        NSIndexPath *path = [_lightView.lightGroups indexPathForItemAtPoint:p];
        
        //        LightGroupCollectionViewCell *c = (LightGroupCollectionViewCell *)[_lightView collectionView:_lightView.lightGroups cellForItemAtIndexPath:path];
        //        NSLog(@"long press ended over item: %@", c);
        NSLog(@"long press ended");
        //        _lightView.hidden = YES;
        //        if (c.group) {
        //            [self setStateForGroup:c.group];
        //        }
    } else {
                NSLog(@"gestureRecognizer.state = %ld", recognizer.state);
    }
}

- (void)viewControllerGestureRecognizerEvent:(UILongPressGestureRecognizer *)gestureRecognizer {
    NSLog(@"got the gesture in color picker");
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
