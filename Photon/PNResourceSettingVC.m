//
//  PNResourceSettingVC.m
//  Photon
//
//  Created by Philip Webster on 5/25/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNResourceSettingVC.h"
#import "PNColorView.h"
#import "PNConstants.h"

@interface PNResourceSettingVC ()

@property (weak, nonatomic) PNLightController *lightController;

@property (weak, nonatomic) IBOutlet UIButton *resourceNameButton;
@property (weak, nonatomic) IBOutlet UIButton *offButton;
@property (weak, nonatomic) IBOutlet UIButton *colorLoopButton;
@property (strong, nonatomic) PNBrightnessPickerVC *brightnessVC;
@property (nonatomic, assign) BOOL shouldShowBrightness;
@property (weak, nonatomic) IBOutlet UIView *brightnessView;
@property (weak, nonatomic) IBOutlet PNColorView *naturalColorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *naturalColorTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *naturalColorHeightConstraint;
@property NSString *otherButtonText;

@end

@implementation PNResourceSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.lightController = [PNLightController singleton];

    self.brightnessVC = [[PNBrightnessPickerVC alloc] init];
    self.brightnessVC.delegate = self;
    
    [self.brightnessView addSubview:self.brightnessVC.view];
    [self.naturalColorView setColors:[[PNLightController singleton] naturalColors]];
    
    UIPanGestureRecognizer *colorTempPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleColorTempPan:)];
    [self.naturalColorView addGestureRecognizer:colorTempPanRecognizer];
    self.naturalColorView.delegate = self;
    
    UIPanGestureRecognizer *bottomCardRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(handleBottomCardPan:)];
    [self.view addGestureRecognizer:bottomCardRecognizer];
    self.otherButtonText = @"Others OFF";
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    self.lightController.lastUsedResource = self.resource;
}

- (void)viewWillAppear:(BOOL)animated {
    self.shouldShowBrightness = NO;
    self.naturalColorView.hidden = NO;
    self.naturalColorHeightConstraint.constant = self.view.bounds.size.height;
    [self moveNaturalColorsUp:NO];

    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:kPNAppGroup];
    NSString *loopingResourceName = [sharedDefaults stringForKey:kPNLoopResourceNameKey];
    if ([loopingResourceName isEqualToString:self.resource.name]) {
        [self.colorLoopButton setTitle:@"Stop color loop" forState:UIControlStateNormal];
        [self.colorLoopButton setUserInteractionEnabled:YES];
    } else if (loopingResourceName) {
        [self.colorLoopButton setTitle:@"Other resource looping" forState:UIControlStateNormal];
        [self.colorLoopButton setUserInteractionEnabled:NO];
    } else {
        self.colorLoopButton.titleLabel.text = @"Color loop";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPressed:(id)sender {
    if (self.brightnessVC.isFirstResponder || !self.shouldShowBrightness) {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.view.frame = CGRectMake(0, CGRectGetHeight(self.view.superview.bounds), self.view.frame.size.width, self.view.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             if (finished){
                                 [self.view removeFromSuperview];
                                 [self removeFromParentViewController];
                             }
                         }];
    }
}

- (IBAction)offButtonPressed:(id)sender {
    [self.lightController setResourceOff:self.resource];
}

- (IBAction)colorLoopButtonPressed:(id)sender {
    if ([self.colorLoopButton.titleLabel.text isEqualToString:@"Stop color loop"]) {
        [self.lightController stopColorLoop];
        [self.colorLoopButton setTitle:@"Color Loop" forState:UIControlStateNormal];
    } else {
        [self.lightController startColorLoopForResource:self.resource transitionTime:60];
        [self.colorLoopButton setTitle:@"Stop color loop" forState:UIControlStateNormal];
    }
}

- (IBAction)othersOffButtonPressed:(id)sender {
    if ([self.otherButtonText isEqualToString:@"Others OFF"]) {
        [self.lightController setOtherResourcesOff];
        self.otherButtonText = @"Others ON";
    } else {
        [self.lightController setOtherResourcesOn];
        self.otherButtonText = @"Others OFF";
    }
}

- (void)setResource:(PHBridgeResource *)resource {
    [self.resourceNameButton setTitle:resource.name forState:UIControlStateNormal];
    self.brightnessVC.resource = resource;
    _resource = resource;
}

- (IBAction)resourceButtonPressed:(id)sender {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.view.frame = CGRectMake(0, CGRectGetHeight(self.view.superview.bounds), self.view.frame.size.width, self.view.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             if (finished){
                                 [self.view removeFromSuperview];
                                 [self removeFromParentViewController];
                             }
                         }];
}

- (void)colorSelected:(UIColor *)color {
    //    NSLog(@"Setting color: %@ for resource: %@", color, self.resource.name);
    [self.lightController setColor:color forResource:self.resource transitionTime:nil completion:nil];
    self.shouldShowBrightness = YES;
}

- (void)naturalColorSelected:(NSNumber *)colorTemp {
    //    NSLog(@"Setting natural color: %@ for resource: %@", colorTemp, self.resource.name);
    [self.lightController setNaturalColor:colorTemp forResource:self.resource];
    self.shouldShowBrightness = YES;
}

- (void)finishedBrightnessSelection {
    
}

- (void)handleColorLoopPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if(recognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"center: %@", NSStringFromCGPoint(recognizer.view.center));
        if (recognizer.view.center.y > 628) {
            recognizer.view.center = CGPointMake(recognizer.view.center.x, 871);
        } else {
            recognizer.view.center = CGPointMake(recognizer.view.center.x, 432);
        }
    }
}

- (void)handleColorTempPan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    if(recognizer.state == UIGestureRecognizerStateEnded) {
        if (recognizer.view.frame.origin.y > self.view.frame.size.height / 3) {
            [self moveNaturalColorsDown:NO];
        } else {
            [self moveNaturalColorsUp:NO];
        }
    }
}

- (void)handleBottomCardPan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (recognizer.view.frame.origin.y > self.view.bounds.size.height / 4) {
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.view.frame = CGRectMake(0, CGRectGetHeight(self.view.superview.bounds), self.view.frame.size.width, self.view.frame.size.height);
                             }
                             completion:^(BOOL finished){
                                 if (finished){
                                     [self.view removeFromSuperview];
                                     [self moveNaturalColorsUp:NO];
                                     [self removeFromParentViewController];
                                 }
                             }];
        } else {
            recognizer.view.frame = self.view.bounds;
        }
    }
}

- (IBAction)longPressedOffButton:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.offButton setTitle:self.otherButtonText forState:UIControlStateNormal];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (!CGRectContainsPoint(self.offButton.frame, [gesture locationInView:self.view])) {
            [self.offButton setTitle:@"OFF" forState:UIControlStateNormal];
            gesture.enabled = NO;
        }
    } else if ( gesture.state == UIGestureRecognizerStateEnded ) {
        if (CGRectContainsPoint(self.offButton.frame, [gesture locationInView:self.view])) {
            [self othersOffButtonPressed:nil];
        }
        [self.offButton setHighlighted:NO];
        [self.offButton setTitle:@"OFF" forState:UIControlStateNormal];
    } else if (gesture.state == UIGestureRecognizerStateCancelled) {
        gesture.enabled = YES;
        [self.offButton setHighlighted:NO];
    }
}

- (void)moveNaturalColorsUp:(BOOL)animated {
    self.naturalColorTopConstraint.constant = - (self.view.bounds.size.height - self.resourceNameButton.frame.size.height - 8 - self.offButton.frame.size.height - 20);
    [self.view setNeedsUpdateConstraints];
}

- (void)moveNaturalColorsDown:(BOOL)animated {
    self.naturalColorTopConstraint.constant = -50;
    [self.view setNeedsUpdateConstraints];
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
