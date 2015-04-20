//
//  PNSettingsVC.m
//  Photon
//
//  Created by Philip Webster on 4/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNSettingsVC.h"
#import "PNLightController.h"
#import "PNAppDelegate.h"

@interface PNSettingsVC ()

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property PNLightController *lightController;

@end

@implementation PNSettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.lightController = [PNLightController singleton];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)resetButtonPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self.lightController resetPhoton];
        [(PNAppDelegate *)[[UIApplication sharedApplication] delegate] doSetupProcess];
//        [(PNAppDelegate *)[[UIApplication sharedApplication] delegate] searchForBridgeLocal];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
