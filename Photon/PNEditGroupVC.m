//
//  PNEditGroupVC.m
//  Photon
//
//  Created by Philip Webster on 4/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNEditGroupVC.h"
#import "PNLightController.h"

@interface PNEditGroupVC ()

@property PHGroup *group;
@property NSMutableSet *selectedLights;
@property PNLightController *lightController;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation PNEditGroupVC

- (id)initWithGroup:(PHGroup *)group {
    self = [super init];
    if (self) {
        self.lightController = [PNLightController singleton];
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
    // Do any additional setup after loading the view from its nib.
    self.groupNameTextField.text = self.group.name ? self.group.name : @"New Group";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lightController.lights.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    PHLight *light = self.lightController.lights[indexPath.row];
    
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
    
    PHLight *light = self.lightController.lights[indexPath.row];
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

- (IBAction)saveButtonPressed:(id)sender {
    NSString *name = self.groupNameTextField.text;
    NSArray *lightIds = [NSArray arrayWithArray:self.selectedLights.allObjects];
    
    if (self.group) {
        // We're updating an existing group
        self.group.name = name;
        self.group.lightIdentifiers = lightIds;
        
        [self.lightController updateGroup:self.group completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];

    } else {
        // We're creating a new group
        [self.lightController createNewGroupWithName:name lightIds:lightIds completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
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
