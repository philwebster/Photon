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
@property PNColorView *standardColorView;
@property PNColorView *focusedView;
@property NSLayoutConstraint *topConstraint;
@property PNLightController *lightController;
@property UITapGestureRecognizer *tapRecognizer;

@end

@implementation PNColorPickerVC

- (id)init {
    // Color picker VC has a resource and generates the different "cards" of colors from some other place
    self = [super init];
    if (self) {
        self.lightController = [PNLightController singleton];

        self.naturalColorView = [[PNColorView alloc] initWithFrame:CGRectZero colors:self.lightController.naturalColors];
        self.naturalColorView.delegate = self;
        self.standardColorView = [[PNColorView alloc] initWithFrame:CGRectZero colors:self.lightController.standardColors];
        self.standardColorView.delegate = self;
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tap:)];
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

    [self.view addSubview:self.naturalColorView];
    [self.view addSubview:self.standardColorView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_naturalColorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_naturalColorView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_naturalColorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_naturalColorView)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_standardColorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_standardColorView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_standardColorView(_naturalColorView)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_standardColorView, _naturalColorView)]];

    self.topConstraint = [NSLayoutConstraint constraintWithItem:_standardColorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-50];
    [self.view addConstraint:self.topConstraint];
    
    self.focusedView = _naturalColorView;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    CGPoint p = [(UITouch *)[touches anyObject] locationInView:self.view];
//    UIView *touchedView = [self.view hitTest:p withEvent:event];
//    if (touchedView == _naturalColorView && self.focusedView != _naturalColorView) {
//        self.topConstraint = [NSLayoutConstraint constraintWithItem:_standardColorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-300];
//    } else if (touchedView == _standardColorView && self.focusedView != _standardColorView) {
//        self.topConstraint = [NSLayoutConstraint constraintWithItem:_standardColorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-50];
//    }
//    [UIView animateWithDuration:0.2 animations:^{
//        [self.view layoutIfNeeded];
//    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)colorSelected:(UIColor *)color {
    NSLog(@"Color selected: %@", color);
    [self.lightController setColor:color forResource:self.resource];
}

- (void)naturalColorSelected:(NSNumber *)colorTemp {
    [self.lightController setNaturalColor:colorTemp forResource:self.resource];
}

- (void)tap:(UITapGestureRecognizer *)tapRecognizer {
    [self.view removeConstraint:self.topConstraint];
    CGPoint p = [tapRecognizer locationInView:self.view];
    if (CGRectContainsPoint(_standardColorView.frame, p)) {
        self.topConstraint = [NSLayoutConstraint constraintWithItem:_standardColorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-600];
        [_standardColorView becomeFirstResponder];
    } else {
        self.topConstraint = [NSLayoutConstraint constraintWithItem:_standardColorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-50];
        [_naturalColorView becomeFirstResponder];
    }
    [self.view addConstraint:self.topConstraint];
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
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
