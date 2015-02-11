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
@property PNColorView *colorView;
@property PNLightController *lightController;

@end

@implementation PNColorPickerVC

- (id)init {
    // Color picker VC has a resource and generates the different "cards" of colors from some other place
    self = [super init];
    if (self) {
        self.lightController = [PNLightController singleton];
        self.colorView = [[PNColorView alloc] initWithFrame:CGRectZero colors:self.lightController.naturalColors];
        self.colorView.delegate = self;
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

- (void)colorSelected:(UIColor *)color {
    NSLog(@"Color selected: %@", color);
    [self.lightController setColor:color forResource:self.resource];
}

- (void)naturalColorSelected:(NSNumber *)colorTemp {
    [self.lightController setNaturalColor:colorTemp forResource:self.resource];
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
