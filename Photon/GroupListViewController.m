//
//  GroupListViewController.m
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "GroupListViewController.h"
#import "EditGroupViewController.h"
#import "AppDelegate.h"
#import <HueSDK_iOS/HueSDK.h>

@interface GroupListViewController ()

@property UITableView *groupTableView;
@property EditGroupViewController *editGroupVC;
@property UIBarButtonItem *createGroupButton;

@end

@implementation GroupListViewController

- (id)init {
    self = [super init];
    if (self) {
        self.groupTableView = [[UITableView alloc] initWithFrame:self.view.frame];
        self.groupTableView.dataSource = self;
        self.groupTableView.delegate = self;
        [self.view addSubview:self.groupTableView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    self.createGroupButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createGroup)];
    self.navigationItem.rightBarButtonItem = self.createGroupButton;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[[PHBridgeResourcesReader readBridgeResourcesCache] groups] allValues] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSArray *groups = [[[PHBridgeResourcesReader readBridgeResourcesCache] groups] allValues];
    cell.textLabel.text = [groups[indexPath.row] name];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *groups = [[[PHBridgeResourcesReader readBridgeResourcesCache] groups] allValues];
    self.editGroupVC = [[EditGroupViewController alloc] initWithGroup:groups[indexPath.row]];
    UINavigationController *navController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navigationController];
    [navController pushViewController:self.editGroupVC animated:YES];
}

- (void)createGroup {
    self.editGroupVC = [[EditGroupViewController alloc] initWithGroup:nil];
    UINavigationController *navController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navigationController];
    [navController pushViewController:self.editGroupVC animated:YES];
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
