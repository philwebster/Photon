//
//  PNColorPickerVC.m
//  Photon
//
//  Created by Philip Webster on 2/2/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNColorPickerVC.h"
#import "PNLightController.h"
#import "PNColorView.h"

@interface PNColorPickerVC ()

@property NSArray *colorViews;
@property PNColorView *naturalColorView;
@property PNColorView *focusedView;
@property NSLayoutConstraint *topConstraint;
@property PNLightController *lightController;
@property UITapGestureRecognizer *tapRecognizer;
@property (nonatomic) UIButton *doneButton;
@property (nonatomic) UIButton *offButton;
@property (nonatomic) UILabel *resourceLabel;
@property PNBrightnessPickerVC *brightnessPicker;
@property (nonatomic, assign) BOOL shouldShowBrightness;

@end

@implementation PNColorPickerVC

- (id)init {
    // Color picker VC has a resource and generates the different "cards" of colors from some other place
    self = [super init];
    if (self) {
        self.lightController = [PNLightController singleton];

        self.naturalColorView = [[PNColorView alloc] initWithFrame:CGRectZero colors:self.lightController.naturalColors];
        self.naturalColorView.delegate = self;
        self.brightnessPicker = [[PNBrightnessPickerVC alloc] init];
        self.brightnessPicker.delegate = self;

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.doneButton];
    
    [self.view addSubview:self.resourceLabel];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_resourceLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_resourceLabel)]];
    [self.view addSubview:self.offButton];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_doneButton(==_offButton)]-8-[_offButton]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_offButton, _doneButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_resourceLabel]-8-[_offButton(120)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_offButton, _resourceLabel)]];
    
    [self.view addSubview:self.naturalColorView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_naturalColorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_naturalColorView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_resourceLabel(50)]-8-[_doneButton(120)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_naturalColorView, _doneButton, _resourceLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_naturalColorView(500)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_naturalColorView, _doneButton, _resourceLabel)]];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_naturalColorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:8];
    [self.view addConstraint:topConstraint];
    
    self.focusedView = _naturalColorView;
    
    UIView *brightnessView = self.brightnessPicker.view;
    [brightnessView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addChildViewController:self.brightnessPicker];
    [self.view bringSubviewToFront:self.naturalColorView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:brightnessView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_doneButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[brightnessView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(brightnessView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[brightnessView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(brightnessView)]];
}

- (void)addChildViewController:(UIViewController *)childController {
    [super addChildViewController:childController];
    [self.view insertSubview:childController.view atIndex:0];
}

- (void)viewWillLayoutSubviews {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.naturalColorView becomeFirstResponder];
    [self clearButtonBackgrounds];
    self.shouldShowBrightness = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    self.brightnessPicker.view.hidden = YES;
    [self animateCard:_naturalColorView direction:YES completion:^{
        self.brightnessPicker.view.hidden = NO;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)colorSelected:(UIColor *)color {
//    NSLog(@"Setting color: %@ for resource: %@", color, self.resource.name);
    [self.lightController setColor:color forResource:self.resource];
    self.shouldShowBrightness = YES;
}

- (void)naturalColorSelected:(NSNumber *)colorTemp {
//    NSLog(@"Setting natural color: %@ for resource: %@", colorTemp, self.resource.name);
    [self.lightController setNaturalColor:colorTemp forResource:self.resource];
    self.shouldShowBrightness = YES;
}

- (void)tappedOffButton {
//    NSLog(@"Setting resource off: %@", self.resource.name);
    [self.lightController setResourceOff:self.resource];
    self.brightnessPicker.view.hidden = YES;
    self.shouldShowBrightness = NO;
    [self animateOut];
}

- (void)tappedDoneButton {
//    NSLog(@"Tapped done button");
    if (self.brightnessPicker.isFirstResponder) {
        [self dismissView];
    } else {
        [self animateOut];
    }
}

- (void)tapAtPoint:(CGPoint)p {
//    NSLog(@"tapping at point: %f, %f", p.x, p.y);

    [self clearButtonBackgrounds];
    if (CGRectContainsPoint(_naturalColorView.frame, p)) {
        [self.naturalColorView becomeFirstResponder];
        [self.naturalColorView updateTouchedViewWithPoint:p];
    } else if (CGRectContainsPoint(_offButton.frame, p)) {
        [self.offButton setBackgroundColor:[UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1]];
    } else if (CGRectContainsPoint(_doneButton.frame, p)) {
        [self.doneButton setBackgroundColor:[UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1]];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)clearButtonBackgrounds {
    [_doneButton setBackgroundColor:[UIColor clearColor]];
    [_offButton setBackgroundColor:[UIColor clearColor]];
}

- (void)setResource:(PHBridgeResource *)resource {
    _resource = resource;
    self.brightnessPicker.resource = resource;
    self.resourceLabel.text = resource.name;
}

- (UILabel *)resourceLabel {
    if (!_resourceLabel) {
        _resourceLabel = [UILabel new];
        [_resourceLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]];
        [_resourceLabel setTextAlignment:NSTextAlignmentCenter];
        [_resourceLabel setTextColor:[UIColor colorWithRed:0.377 green:0.377 blue:0.377 alpha:1]];
        [_resourceLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _resourceLabel;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton new];
        [_doneButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:24]];
        [_doneButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_doneButton setTitleColor:[UIColor colorWithRed:0.377 green:0.377 blue:0.377 alpha:1] forState:UIControlStateNormal];
        [_doneButton setTitle:@"DONE" forState:UIControlStateNormal];
        [_doneButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_doneButton addTarget:self action:@selector(tappedDoneButton) forControlEvents:UIControlEventTouchUpInside];
        [_doneButton setTitleColor:[UIColor colorWithRed:0.185 green:0.185 blue:0.185 alpha:1] forState:UIControlStateHighlighted];
        _doneButton.layer.cornerRadius = 8;
    }
    return _doneButton;
}

- (UIButton *)offButton {
    if (!_offButton) {
        _offButton = [UIButton new];
        [_offButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:24]];
        [_offButton setTitleColor:[UIColor colorWithRed:0.377 green:0.377 blue:0.377 alpha:1] forState:UIControlStateNormal];
        [_offButton setTitle:@"OFF" forState:UIControlStateNormal];
        [_offButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_offButton addTarget:self action:@selector(tappedOffButton) forControlEvents:UIControlEventTouchUpInside];
        [_offButton setTitleColor:[UIColor colorWithRed:0.185 green:0.185 blue:0.185 alpha:1] forState:UIControlStateHighlighted];
        _offButton.layer.cornerRadius = 8;
    }
    return _offButton;
}

- (void)dismissView {
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        self.view.alpha = 1.0;
        self.naturalColorView.touchedView = nil;
        [self.colorDelegate dismissedColorPicker];
    }];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    CGPoint p = [recognizer locationInView:self.view];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.naturalColorView.longPressMode = NO;
        BOOL showBrightness = YES;
        if (CGRectContainsPoint(self.offButton.frame, p)) {
            [self tappedOffButton];
            showBrightness = NO;
        }
        [self animateOut];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.naturalColorView.longPressMode = YES;
        [self tapAtPoint:p];
    }
}

- (void)animateOut {
    if (!self.shouldShowBrightness) {
        self.brightnessPicker.view.hidden = YES;
    }
    [self animateCard:_naturalColorView direction:NO completion:^{
        if (self.shouldShowBrightness) {
            [self.brightnessPicker becomeFirstResponder];
            [self.brightnessPicker startFadingAfterInterval:7.0];
        } else {
            [self dismissView];
        }
    }];
}

- (NSLayoutConstraint *)topConstraintForView:(UIView *)view {
    NSLayoutConstraint *topConstraint;
    for (NSLayoutConstraint *constraint in self.view.constraints) {
        if (constraint.firstItem == view && constraint.firstAttribute == NSLayoutAttributeTop) {
            topConstraint = constraint;
            break;
        }
    }
    return topConstraint;
}

- (void)animateCard:(UIView *)card direction:(BOOL)direction completion:(void (^)())completion {
    if (self.shouldShowBrightness) {
        self.brightnessPicker.view.hidden = NO;
    }
    
    [self.view removeConstraint:[self topConstraintForView:card]];
    NSLayoutConstraint *newTopConstraint;
    if (direction) {
        newTopConstraint = [NSLayoutConstraint constraintWithItem:card attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_doneButton attribute:NSLayoutAttributeBottom multiplier:1 constant:8];
    } else {
        newTopConstraint = [NSLayoutConstraint constraintWithItem:card attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    }
    [self.view addConstraint:newTopConstraint];
    [UIView animateWithDuration:0.2 animations:^{
        if (direction) {
            self.view.backgroundColor = [UIColor whiteColor];
        } else {
            self.view.backgroundColor = [UIColor whiteColor];
        }
        [self clearButtonBackgrounds];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];

}

- (void)finishedBrightnessSelection {
    [self dismissView];
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
