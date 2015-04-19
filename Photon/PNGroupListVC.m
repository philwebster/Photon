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

@interface PNGroupListVC ()

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property PNLightController *lightController;

@end

@implementation PNGroupListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.lightController = [PNLightController singleton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lightController.groups.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        NSArray *groups = [[[PHBridgeResourcesReader readBridgeResourcesCache] groups] allValues];
        NSString *groupID = [groups[indexPath.row] identifier];
        
        PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
        __weak UITableView *weakTableView = tableView;
        [bridgeSendAPI removeGroupWithId:groupID completionHandler:^(NSArray *errors) {
            if (!errors) {
                [weakTableView reloadData];
            }
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSArray *groups = self.lightController.groups;
    cell.textLabel.text = [groups[indexPath.row] name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *groups = self.lightController.groups;
    PNEditGroupVC *editVC = [[PNEditGroupVC alloc] initWithGroup:groups[indexPath.row]];
    [self.navigationController pushViewController:editVC animated:YES];
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
