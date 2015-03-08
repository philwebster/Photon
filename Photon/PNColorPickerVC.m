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

@end

@implementation PNColorPickerVC

- (id)init {
    // Color picker VC has a resource and generates the different "cards" of colors from some other place
    self = [super init];
    if (self) {
        self.lightController = [PNLightController singleton];

        self.naturalColorView = [[PNColorView alloc] initWithFrame:CGRectZero colors:self.lightController.naturalColors];
        self.naturalColorView.delegate = self;
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        self.tapRecognizer.numberOfTapsRequired = 1;
        self.tapRecognizer.delegate = self;
        [self.tapRecognizer setCancelsTouchesInView:YES];
        
        [self.view addGestureRecognizer:self.tapRecognizer];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.view addSubview:self.doneButton];
    
    [self.view addSubview:self.resourceLabel];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_resourceLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_resourceLabel)]];
    [self.view addSubview:self.offButton];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_doneButton(==_offButton)][_offButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_offButton, _doneButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_resourceLabel][_offButton(120)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_offButton, _resourceLabel)]];
    
    [self.view addSubview:self.naturalColorView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_naturalColorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_naturalColorView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_resourceLabel(50)][_doneButton(120)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_naturalColorView, _doneButton, _resourceLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_naturalColorView(500)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_naturalColorView, _doneButton, _resourceLabel)]];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_naturalColorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view addConstraint:topConstraint];


    self.focusedView = _naturalColorView;
}

- (void)viewWillLayoutSubviews {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.naturalColorView becomeFirstResponder];
    [self clearButtonBackgrounds];
}

- (void)viewDidAppear:(BOOL)animated {
    [self animateCard:_naturalColorView direction:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)colorSelected:(UIColor *)color {
    NSLog(@"Setting color: %@ for resource: %@", color, self.resource.name);
    [self.lightController setColor:color forResource:self.resource];
}

- (void)naturalColorSelected:(NSNumber *)colorTemp {
    NSLog(@"Setting natural color: %@ for resource: %@", colorTemp, self.resource.name);
    [self.lightController setNaturalColor:colorTemp forResource:self.resource];
}

- (void)tappedOffButton {
    NSLog(@"Setting resource off: %@", self.resource.name);
    [self.lightController setResourceOff:self.resource];
}

- (void)tap:(UITapGestureRecognizer *)tapRecognizer {
    [self.view removeConstraint:self.topConstraint];
    CGPoint p = [tapRecognizer locationInView:self.view];
    [self tapAtPoint:p];
}

- (void)tapAtPoint:(CGPoint)p {
//    NSLog(@"tapping at point: %f, %f", p.x, p.y);

    [self clearButtonBackgrounds];
    if (CGRectContainsPoint(_naturalColorView.frame, p)) {
        [_naturalColorView becomeFirstResponder];
        [_naturalColorView updateTouchedViewWithPoint:p];
    } else if (CGRectContainsPoint(_offButton.frame, p)) {
        [_offButton setBackgroundColor:[UIColor grayColor]];
    } else if (CGRectContainsPoint(_doneButton.frame, p)) {
        [_doneButton setBackgroundColor:[UIColor grayColor]];
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
    self.resourceLabel.text = resource.name;
}

- (UILabel *)resourceLabel {
    if (!_resourceLabel) {
        _resourceLabel = [UILabel new];
        [_resourceLabel setTextAlignment:NSTextAlignmentCenter];
        [_resourceLabel setTextColor:[UIColor whiteColor]];
        [_resourceLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _resourceLabel;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton new];
        [_doneButton.titleLabel setFont:[_doneButton.titleLabel.font fontWithSize:24]];
        [_doneButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton setTitle:@"DONE" forState:UIControlStateNormal];
        [_doneButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_doneButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (UIButton *)offButton {
    if (!_offButton) {
        _offButton = [UIButton new];
        [_offButton.titleLabel setFont:[_offButton.titleLabel.font fontWithSize:24]];
        [_offButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_offButton setTitle:@"OFF" forState:UIControlStateNormal];
        [_offButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_offButton addTarget:self action:@selector(tappedOffButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _offButton;
}

- (void)dismissView {
    [self.view removeFromSuperview];
    [self.delegate dismissedColorPicker];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    CGPoint p = [recognizer locationInView:self.view];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (CGRectContainsPoint(self.offButton.frame, p)) {
            [self tappedOffButton];
        }
        [self animateCard:_naturalColorView direction:NO completion:^{
            [self dismissView];
        }];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self tapAtPoint:p];
    }
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
    [self.view removeConstraint:[self topConstraintForView:card]];
    NSLayoutConstraint *newTopConstraint;
    if (direction) {
        newTopConstraint = [NSLayoutConstraint constraintWithItem:card attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_doneButton attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    } else {
        newTopConstraint = [NSLayoutConstraint constraintWithItem:card attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    }
    [self.view addConstraint:newTopConstraint];
    [UIView animateWithDuration:0.2 animations:^{
        if (direction) {
            self.view.backgroundColor = [UIColor blackColor];
        } else {
            self.view.backgroundColor = [UIColor clearColor];
        }
        [self clearButtonBackgrounds];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];

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
