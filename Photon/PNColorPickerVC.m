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
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
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
    
    [self.view addSubview:self.resourceLabel];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_resourceLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_resourceLabel)]];
    [self.view addSubview:self.offButton];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_cancelButton(==_offButton)][_offButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_offButton, _cancelButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_resourceLabel][_offButton(120)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_offButton, _resourceLabel)]];
    
    [self.view addSubview:self.naturalColorView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_naturalColorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_naturalColorView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_resourceLabel(50)][_cancelButton(120)]-[_naturalColorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_naturalColorView, _cancelButton, _resourceLabel)]];

    self.focusedView = _naturalColorView;
    [self clearButtonBackgrounds];
}

- (void)viewWillLayoutSubviews {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.naturalColorView becomeFirstResponder];
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
    } else if (CGRectContainsPoint(_cancelButton.frame, p)) {
        [_cancelButton setBackgroundColor:[UIColor grayColor]];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)clearButtonBackgrounds {
    [_cancelButton setBackgroundColor:[UIColor clearColor]];
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

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton new];
        [_cancelButton.titleLabel setFont:[_cancelButton.titleLabel.font fontWithSize:24]];
        [_cancelButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
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
        [_offButton.titleLabel setFont:[_offButton.titleLabel.font fontWithSize:24]];
        [_offButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_offButton setTitle:@"OFF" forState:UIControlStateNormal];
        [_offButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_offButton addTarget:self action:@selector(tappedOffButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _offButton;
}

- (void)tappedOffButton {
    [self.lightController setResourceOff:self.resource];
    [self dismissView];
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
        } else {
            [self dismissView];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self tapAtPoint:p];
    }
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
