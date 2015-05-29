//
//  PNResourceSettingVC.m
//  Photon
//
//  Created by Philip Webster on 5/25/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNResourceSettingVC.h"

@interface PNResourceSettingVC ()

@property (weak, nonatomic) PNLightController *lightController;

@property (weak, nonatomic) IBOutlet UILabel *resourceNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *offButton;
@property (weak, nonatomic) IBOutlet UIButton *colorLoopButton;
@property (weak, nonatomic) IBOutlet UIButton *othersOffButton;
@property (weak, nonatomic) IBOutlet PNColorView *naturalColorView;
@property (strong, nonatomic) PNBrightnessPickerVC *brightnessVC;
@property (weak, nonatomic) IBOutlet UIView *brightnessView;
@property (nonatomic, assign) BOOL shouldShowBrightness;

@end

@implementation PNResourceSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.lightController = [PNLightController singleton];

    self.naturalColorView.delegate = self;
    [self.naturalColorView setColors:self.lightController.naturalColors];
    
    self.brightnessVC = [[PNBrightnessPickerVC alloc] init];
    self.brightnessVC.delegate = self;
    
    [self.brightnessView addSubview:self.brightnessVC.view];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    self.lightController.lastUsedResource = self.resource;
}

- (void)viewDidDisappear:(BOOL)animated {
    self.naturalColorView.touchedView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    self.shouldShowBrightness = NO;
    self.naturalColorView.hidden = NO;
}

- (void)viewWillLayoutSubviews {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.phil.photon"];
    if ([[sharedDefaults stringForKey:@"loop resource"] isEqualToString:self.resource.name]) {
        self.colorLoopButton.titleLabel.text = @"Stop color loop";
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
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    } else {
        self.naturalColorView.hidden = YES;
        [self.brightnessVC becomeFirstResponder];
    }
}

- (IBAction)offButtonPressed:(id)sender {
    [self.lightController setResourceOff:self.resource];
}

- (IBAction)colorLoopButtonPressed:(id)sender {
    if ([self.colorLoopButton.titleLabel.text isEqualToString:@"Stop color loop"]) {
        [self.lightController stopColorLoop];
    } else {
        [self.lightController startColorLoopForResource:self.resource transitionTime:60];
        self.colorLoopButton.titleLabel.text = @"Stop color loop";
    }
}

- (IBAction)othersOffButtonPressed:(id)sender {
    if ([self.othersOffButton.titleLabel.text isEqualToString:@"Others OFF"]) {
        [self.lightController setOtherResourcesOff];
        self.othersOffButton.titleLabel.text = @"Others ON";
    } else {
        [self.lightController setOtherResourcesOn];
        self.othersOffButton.titleLabel.text = @"Others OFF";
    }
}

- (void)setResource:(PHBridgeResource *)resource {
    self.resourceNameLabel.text = resource.name;
    self.brightnessVC.resource = resource;
    _resource = resource;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
