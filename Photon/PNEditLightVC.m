//
//  PNEditLightVC.m
//  Photon
//
//  Created by Philip Webster on 4/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNEditLightVC.h"
#import "PNLightController.h"

@interface PNEditLightVC ()

@property PHLight *light;
@property PNLightController *lightController;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextField *lightNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation PNEditLightVC

- (id)initWithLight:(PHLight *)light {
    self = [super init];
    if (self) {
        self.lightController = [PNLightController singleton];
        self.light = light;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.lightNameTextField.text = self.light.name;
    [self.lightNameTextField setTintColor:[UIColor colorWithRed:0.301 green:0.301 blue:0.301 alpha:1]];
    [self.lightNameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonPressed:(id)sender {
    self.light.name = self.lightNameTextField.text;
    [self.lightController updateLight:self.light completion:^(NSArray *errors) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)lightNameEdited:(id)sender {
    [self updateSaveButtonState];
}

#pragma mark Buttons

- (void)updateSaveButtonState {
    self.saveButton.enabled = self.lightNameTextField.text.length > 0;
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
