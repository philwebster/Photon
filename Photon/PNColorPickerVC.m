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

@property PNLightController *lightController;
@property NSArray *colorViews;
@property PNColorView *colorView;

@end

@implementation PNColorPickerVC

- (id)initWithColors:(NSArray *)colors {
    self = [super init];
    if (self) {
        self.colorView = [[PNColorView alloc] initWithFrame:CGRectZero colors:colors];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.view addSubview:self.colorView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_colorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_colorView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_colorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_colorView)]];
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
