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
@property (nonatomic) UIButton *cancelButton;
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
        self.standardColorView = [[PNColorView alloc] initWithFrame:CGRectZero colors:self.lightController.standardColors];
        self.standardColorView.delegate = self;
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tap:)];
        self.tapRecognizer.numberOfTapsRequired = 1;
        self.tapRecognizer.delegate = self;
        [self.tapRecognizer setCancelsTouchesInView:YES];
        
        [self.view addGestureRecognizer:self.tapRecognizer];
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.view addSubview:self.cancelButton];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_cancelButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cancelButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_cancelButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cancelButton)]];
    
    [self.view addSubview:self.resourceLabel];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.resourceLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.resourceLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.cancelButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_resourceLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_resourceLabel)]];
    
    [self.view addSubview:self.offButton];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_offButton]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_offButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_offButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_offButton)]];

    
    [self.view addSubview:self.naturalColorView];
    [self.view addSubview:self.standardColorView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_naturalColorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_naturalColorView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_cancelButton]-[_naturalColorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_naturalColorView, _cancelButton)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_standardColorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_standardColorView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_standardColorView(_naturalColorView)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_standardColorView, _naturalColorView)]];

    self.topConstraint = [NSLayoutConstraint constraintWithItem:_standardColorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-50];
    [self.view addConstraint:self.topConstraint];
    
    self.focusedView = _naturalColorView;
}

- (void)viewWillLayoutSubviews {
    
}


- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
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
        self.topConstraint = [NSLayoutConstraint constraintWithItem:_standardColorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-550];
        [_standardColorView becomeFirstResponder];
    } else {
        self.topConstraint = [NSLayoutConstraint constraintWithItem:_standardColorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-70];
        [_naturalColorView becomeFirstResponder];
    }
    [self.view addConstraint:self.topConstraint];
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];

}

- (void)setResource:(PHBridgeResource *)resource {
    _resource = resource;
    self.resourceLabel.text = resource.name;
}

- (UILabel *)resourceLabel {
    if (!_resourceLabel) {
        _resourceLabel = [UILabel new];
        [_resourceLabel setTextColor:[UIColor whiteColor]];
        [_resourceLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _resourceLabel;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton new];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_cancelButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)offButton {
    if (!_offButton) {
        _offButton = [UIButton new];
        [_offButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_offButton setTitle:@"OFF" forState:UIControlStateNormal];
        [_offButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_offButton addTarget:self action:@selector(setResourceOff) forControlEvents:UIControlEventTouchUpInside];
    }
    return _offButton;
}

- (void)setResourceOff {
    [self.lightController setResourceOff:self.resource];
}

- (void)dismissView {
    [self.view removeFromSuperview];
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
