//
//  PNBrightnessPickerVC.m
//  Photon
//
//  Created by Philip Webster on 3/8/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNBrightnessPickerVC.h"
#import "PNLightController.h"
#import "PNBrightnessCell.h"

@interface PNBrightnessPickerVC ()

@property UISlider *mainSlider;
@property UITableView *table;
@property BOOL willUpdateBrightness;
@property PNLightController *lightController;

@end

@implementation PNBrightnessPickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lightController = [PNLightController singleton];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.mainSlider = [[UISlider alloc] init];
    self.mainSlider.minimumValue = 0;
    self.mainSlider.maximumValue = 255;
    self.mainSlider.continuous = YES;
    self.mainSlider.value = 255;
    [self.mainSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.table = [[UITableView alloc] initWithFrame:self.view.frame];
    self.table.dataSource = self;
    self.table.delegate = self;
    self.table.rowHeight = 110.0;
    [self.view addSubview:self.table];
    
    self.table.tableHeaderView = self.mainSlider;
    self.view.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.table reloadData];
    if ([self.resource isKindOfClass:[PHLight class]]) {
        PHLight *light = (PHLight *)self.resource;
        self.mainSlider.value = [light.lightState.brightness floatValue];
    } else if ([self.resource isKindOfClass:[PHGroup class]]) {
        // TODO: set as average of group
        PHGroup *group = (PHGroup *)self.resource;
        self.mainSlider.value = [[self.lightController averageBrightnessForGroup:group] floatValue];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numRows = 0;
    if ([self.resource isKindOfClass:[PHLight class]]) {
        numRows = 0;
    } else if ([self.resource isKindOfClass:[PHGroup class]]) {
        PHGroup *group = (PHGroup *)self.resource;
        numRows = [group.lightIdentifiers count];
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PNBrightnessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"brightnessCell"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"PNBrightnessCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"brightnessCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"brightnessCell"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.resource isKindOfClass:[PHGroup class]]) {
        PHGroup *group = (PHGroup *)self.resource;
        PHLight *light = [self.lightController lightWithId:[group.lightIdentifiers objectAtIndex:indexPath.row]];
        PNBrightnessCell *brightnessCell = (PNBrightnessCell *)cell;
        brightnessCell.resource = light;
    }
}

- (void)sliderChanged:(id)sender {
    if (!self.willUpdateBrightness) {
        NSLog(@"updating brightness in 0.5");
        [self performSelector:@selector(updateBrightness:) withObject:self.mainSlider afterDelay:0.5];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(done) object:nil];
        [self performSelector:@selector(done) withObject:nil afterDelay:3.0];
        self.willUpdateBrightness = YES;
    }
}

- (void)updateBrightness:(id)sender {
    NSNumber *brightnessVal = [NSNumber numberWithInt:[[NSNumber numberWithFloat:self.mainSlider.value] intValue]];
    [self.delegate brightnessUpdated:brightnessVal];
    self.willUpdateBrightness = NO;
}

- (void)startFadingAfterInterval:(NSTimeInterval)interval {
    [self performSelector:@selector(done) withObject:nil afterDelay:interval];
}

- (void)removeFromParentViewController {
    [super removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (void)done {
    self.view.hidden = YES;
    [self.delegate finishedBrightnessSelection];
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
