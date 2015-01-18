//
//  ViewController.m
//  Photon
//
//  Created by Philip Webster on 1/15/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "ViewController.h"
#import "LightGroupView.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *colorCollection;
@property (strong, nonatomic) LightGroupView *lightView;

@property NSMutableArray *colors;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    _colors = [NSMutableArray arrayWithArray:@[[UIColor colorWithRed:0 green:0 blue:0 alpha:1],
//                                               [UIColor colorWithHue:0.123 saturation:0.665 brightness:0.996 alpha:1.000],
//                                               [UIColor colorWithHue:0.132 saturation:0.227 brightness:1.000 alpha:1.000],
//                                               [UIColor colorWithHue:0.167 saturation:0.012 brightness:1.000 alpha:1.000],
//                                               [UIColor colorWithHue:0.549 saturation:0.200 brightness:1.000 alpha:1.000],
//                                               [UIColor colorWithHue:0.540 saturation:0.409 brightness:0.922 alpha:1.000]]];

    _colors = [NSMutableArray arrayWithArray:@[[UIColor colorWithWhite:0.000 alpha:1.000],
                                               [UIColor colorWithHue:0.626 saturation:0.871 brightness:1.000 alpha:1.000],
                                               [UIColor colorWithHue:0.788 saturation:1.000 brightness:0.996 alpha:1.000],
                                               [UIColor colorWithHue:0.846 saturation:1.000 brightness:0.984 alpha:1.000],
                                               [UIColor colorWithHue:0.965 saturation:1.000 brightness:0.984 alpha:1.000],
                                               [UIColor colorWithHue:0.081 saturation:0.881 brightness:0.992 alpha:1.000],
                                               [UIColor colorWithHue:0.155 saturation:0.941 brightness:0.996 alpha:1.000],
                                               [UIColor colorWithHue:0.341 saturation:0.748 brightness:1.000 alpha:1.000],
                                               [UIColor colorWithHue:0.468 saturation:0.808 brightness:1.000 alpha:1.000]]];
    
    _lightView = [[LightGroupView alloc] initWithFrame:self.view.frame];
    _lightView.hidden = YES;

    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    recognizer.minimumPressDuration = 0.1;
    recognizer.delegate = self;
    [self.colorCollection addGestureRecognizer:recognizer];

    [self.view addSubview:_lightView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_colors count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIColor *color = self.colors[indexPath.row];
    cell.backgroundColor = color;
    return cell;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    _lightView.hidden = NO;
    [self.view bringSubviewToFront:_lightView];
    CGPoint p = [recognizer locationInView:self.colorCollection];
    
    NSIndexPath *indexPath = [self.colorCollection indexPathForItemAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on view but not on a row");
    } else if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long press on view at row %ld", (long)indexPath.row);
        _lightView.hidden = NO;
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSIndexPath *path = [_lightView.lightGroups indexPathForItemAtPoint:p];
        UIColor *c = [_lightView.lightGroups cellForItemAtIndexPath:path].backgroundColor;
        NSLog(@"long press ended over item: %@", c);
        _lightView.hidden = YES;
    } else {
        NSLog(@"gestureRecognizer.state = %ld", recognizer.state);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width, 100);
}
@end
