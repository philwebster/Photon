//
//  EditGroupViewController.m
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "EditGroupViewController.h"
#import <HueSDK_iOS/HueSDK.h>
#import "AppDelegate.h"

@interface EditGroupViewController ()

@property UITableView *lightsTableView;
@property NSMutableSet *selectedLights;
@property UIBarButtonItem *saveButton;
@property PHGroup *group;
@property UITextField *groupTitleField;

@end

@implementation EditGroupViewController

- (id)initWithGroup:(PHGroup *)group {
    self = [super init];
    if (self) {
        self.group = group;
        self.selectedLights = [NSMutableSet set];        
        for (NSString *light in [group lightIdentifiers]) {
            [self.selectedLights addObject:light];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lightsTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.lightsTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.lightsTableView.dataSource = self;
    self.lightsTableView.delegate = self;
    self.lightsTableView.allowsMultipleSelection = YES;
//    [self.view addSubview:self.lightsTableView];
    
    self.groupTitleField = [[UITextField alloc] init];
    self.groupTitleField.borderStyle = UITextBorderStyleBezel;
    [self.groupTitleField setAutoresizesSubviews:NO];
    self.groupTitleField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.groupTitleField];
    
//    [self.view setAutoresizesSubviews:NO];
//    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_groupTitleField]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lightsTableView, _groupTitleField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_groupTitleField(50.0)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lightsTableView, _groupTitleField)]];

    self.view.backgroundColor = [UIColor orangeColor];
    self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveGroup)];
    self.navigationItem.rightBarButtonItem = self.saveButton;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[[PHBridgeResourcesReader readBridgeResourcesCache] lights] allValues] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    PHLight *light = [[[PHBridgeResourcesReader readBridgeResourcesCache] lights] allValues][indexPath.row];

    if ([self.selectedLights containsObject:[light identifier]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.textLabel.text = [light name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];

    PHLight *light = [[[PHBridgeResourcesReader readBridgeResourcesCache] lights] allValues][indexPath.row];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        // Reflect selection in data model
        [self.selectedLights addObject:[light identifier]];
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        // Reflect deselection in data model
        [self.selectedLights removeObject:[light identifier]];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)saveGroup {
    // Get group from cache
    
    // Update name of group
//    group.name = @”New name of group”;

    self.group.lightIdentifiers = [NSArray arrayWithArray:[self.selectedLights allObjects]];
    
    // Create PHBridgeSendAPI object
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    // Call update of group on bridge API
    [bridgeSendAPI updateGroupWithGroup:self.group completionHandler:^(NSArray *errors) {
        if (!errors){
            // Update successful
            NSLog(@"successfully updated group");
        } else {
            // Error occurred
            NSLog(@"didn't update group");
        }
    }];
}

- (void)createNewGroup {
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];

    [bridgeSendAPI createGroupWithName:@"New Group" lightIds:[NSArray arrayWithArray:[self.selectedLights allObjects]] completionHandler:^(NSString *groupIdentifier, NSArray *errors) {
        if (!errors){
            // Create successful
            NSLog(@"successfully created group");
        } else {
            // Error occurred
            NSLog(@"didn't create group");
        }
    }];
}

@end
