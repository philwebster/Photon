//
//  PNGroupListVC.m
//  Photon
//
//  Created by Philip Webster on 4/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNGroupListVC.h"
#import "PNLightController.h"
#import "PNEditGroupVC.h"
#import "PNEditLightVC.h"

@interface PNGroupListVC ()

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property PNLightController *lightController;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) NSArray *tableData;
@property (nonatomic, assign) BOOL displayLights;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *resourceTypeLabel;

@end

@implementation PNGroupListVC

- (id)initWithLights {
    self = [super init];
    if (self) {
        self.displayLights = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.lightController = [PNLightController singleton];
    self.table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if (self.displayLights) {
        self.addButton.hidden = YES;
        self.resourceTypeLabel.text = @"Lights";
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self.table reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        __weak UITableView *weakTableView = tableView;
        [self.lightController deleteGroup:self.lightController.groups[indexPath.row] completion:^(NSArray *errors) {
            // TODO: We're not handling any errors here
            [weakTableView reloadData];
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:22];
        cell.textLabel.textColor = [UIColor colorWithRed:0.377 green:0.377 blue:0.377 alpha:1];
        cell.tintColor = [UIColor colorWithRed:0.354 green:0.592 blue:0.764 alpha:1];
    }

    cell.textLabel.text = [self.tableData[indexPath.row] name];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.displayLights) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.displayLights) {
        PNEditLightVC *editVC = [[PNEditLightVC alloc] initWithLight:self.tableData[indexPath.row]];
        [self.navigationController pushViewController:editVC animated:YES];
    } else {
        PNEditGroupVC *editVC = [[PNEditGroupVC alloc] initWithGroup:self.tableData[indexPath.row]];
        [self.navigationController pushViewController:editVC animated:YES];
    }
}

- (IBAction)newGroupButtonPressed:(id)sender {
    PNEditGroupVC *editVC = [[PNEditGroupVC alloc] initWithGroup:nil];
    [self.navigationController pushViewController:editVC animated:YES];
}

- (NSArray *)tableData {
    if (self.displayLights) {
        return self.lightController.lights;
    } else {
        return self.lightController.groups;
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
