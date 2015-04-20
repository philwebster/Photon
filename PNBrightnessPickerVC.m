//
//  PNBrightnessPickerVC.m
//  Photon
//
//  Created by Philip Webster on 3/8/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNBrightnessPickerVC.h"
#import "PNLightController.h"

#define MAX_BRIGHTNESS 254

@interface PNBrightnessPickerVC ()

@property (weak, nonatomic) IBOutlet UISlider *mainSlider;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property BOOL willUpdateBrightness;
@property PNLightController *lightController;
@property NSMutableDictionary *lightBrightnessValues;
@property NSMutableDictionary *lightBrightnessInitialValues;
@property NSInteger initialMainSliderValue;

@end

@implementation PNBrightnessPickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lightController = [PNLightController singleton];
    
    self.mainSlider.minimumValue = 0;
    self.mainSlider.maximumValue = MAX_BRIGHTNESS;
    self.mainSlider.continuous = YES;
    self.mainSlider.value = MAX_BRIGHTNESS;
    [self.mainSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [self.mainSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.table.dataSource = self;
    self.table.delegate = self;
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
        self.initialMainSliderValue = self.mainSlider.value;
        self.lightBrightnessValues = [NSMutableDictionary dictionary];
        for (PHLight *light in [self.lightController lightsForGroup:group]) {
            NSNumber *brightness = light.lightState.brightness;
            if (!brightness) {
                brightness = @0;
            }
            [self.lightBrightnessValues setObject:brightness forKey:light.identifier];
        }
        self.lightBrightnessInitialValues = [self.lightBrightnessValues mutableCopy];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(done) object:nil];
    self.lightBrightnessValues = nil;
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
        brightnessCell.delegate = self;
    }
}

- (void)sliderChanged:(id)sender {
    if ([sender isKindOfClass:[PNBrightnessCell class]]) {
        PNBrightnessCell *cell = (PNBrightnessCell *)sender;
        UISlider *slider = cell.resourceBrightnessSlider;
        PHLight *light = (PHLight *)cell.resource;
        [self.lightBrightnessValues setObject:[NSNumber numberWithInt:(int)slider.value] forKey:light.identifier];
        self.lightBrightnessInitialValues = [self.lightBrightnessValues mutableCopy];
        self.mainSlider.value = self.initialMainSliderValue = [self averageBrightness:self.lightBrightnessValues];
    }
    if (sender == self.mainSlider) {
        __weak PNBrightnessPickerVC *weakSelf = self;
        [self.lightBrightnessValues enumerateKeysAndObjectsUsingBlock:^(NSString *lightID, NSNumber *brightness, BOOL *stop) {
            CGFloat newBrightness;
            CGFloat initialBrightness = [[weakSelf.lightBrightnessInitialValues objectForKey:lightID] floatValue];
            if (weakSelf.mainSlider.value > weakSelf.initialMainSliderValue) {
                // initial value + difference * percent
                CGFloat difference = MAX_BRIGHTNESS - initialBrightness;
                newBrightness = initialBrightness + difference * ((weakSelf.mainSlider.value - weakSelf.initialMainSliderValue) / (MAX_BRIGHTNESS - weakSelf.initialMainSliderValue));
            } else {
                // initial value - difference * percent
                newBrightness = initialBrightness - initialBrightness * (1 - (weakSelf.mainSlider.value / weakSelf.initialMainSliderValue));
            }
            [weakSelf.lightBrightnessValues setObject:[NSNumber numberWithInt:(int)newBrightness] forKey:lightID];
        }];
        for (PNBrightnessCell *cell in weakSelf.table.visibleCells) {
            cell.resourceBrightnessSlider.value = [[weakSelf.lightBrightnessValues objectForKey:cell.resource.identifier] floatValue];
        }
    }
    if (!self.willUpdateBrightness) {
        NSLog(@"updating brightness in 0.25");
        [self performSelector:@selector(updateBrightness:) withObject:self afterDelay:0.25];
        self.willUpdateBrightness = YES;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(done) object:nil];
    [self performSelector:@selector(done) withObject:nil afterDelay:5.0];
}

- (void)updateBrightness:(id)sender {
    if ([self.resource isKindOfClass:[PHLight class]]) {
        [self.lightController setBrightness:[NSNumber numberWithInt:(int)self.mainSlider.value] forResource:self.resource];
    } else {
        __weak PNBrightnessPickerVC *weakSelf = self;
        [self.lightBrightnessValues enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, NSNumber *brightnessVal, BOOL *stop) {
            PHLight *light = [weakSelf.lightController lightWithId:identifier];
            [weakSelf.lightController setBrightness:brightnessVal forResource:light];
        }];
    }
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
    [self.delegate finishedBrightnessSelection];
}

- (NSInteger)averageBrightness:(NSDictionary *)brightnessValues {
    __block NSInteger average = 0;
    [brightnessValues enumerateKeysAndObjectsUsingBlock:^(PHLight *light, NSNumber *brightness, BOOL *stop) {
        average += [brightness integerValue];
    }];
    average = average / brightnessValues.count;
    return average;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
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
