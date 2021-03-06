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
@property (weak, nonatomic) IBOutlet UIButton *deleteGroupButton;
@property (weak, nonatomic) IBOutlet UITableView *lightTable;

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
    self.groupNameTextField.text = self.group.name;
    [self.groupNameTextField setTintColor:[UIColor colorWithRed:0.301 green:0.301 blue:0.301 alpha:1]];
    if (!self.group) {
        [self.groupNameTextField becomeFirstResponder];
    }
    self.deleteGroupButton.enabled = self.group != nil;
    self.saveButton.enabled = self.group != nil;
    self.lightTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:22];
        cell.textLabel.textColor = [UIColor colorWithRed:0.377 green:0.377 blue:0.377 alpha:1];
        cell.tintColor = [UIColor colorWithRed:0.354 green:0.592 blue:0.764 alpha:1];
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
    [self.groupNameTextField resignFirstResponder];
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
    [self updateSaveButtonState];
}

- (IBAction)saveButtonPressed:(id)sender {
    NSString *name = self.groupNameTextField.text;
    NSArray *lightIds = [NSArray arrayWithArray:self.selectedLights.allObjects];
    
    if (self.group) {
        // We're updating an existing group
        self.group.name = name;
        self.group.lightIdentifiers = lightIds;
        
        [self.lightController updateGroup:self.group completion:^(NSArray *errors) {
            if (!errors){
                NSLog(@"successfully updated group");
            } else {
                NSLog(@"error updating group");
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];

    } else {
        // We're creating a new group
        [self.lightController createNewGroupWithName:name lightIds:lightIds completion:^(NSArray *errors) {
            if (!errors){
                NSLog(@"successfully created group");
            } else {
                NSLog(@"error creating group");
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)groupNameEdited:(id)sender {
    [self updateSaveButtonState];
}

#pragma mark Buttons

- (void)updateSaveButtonState {
    self.saveButton.enabled = self.selectedLights.count > 0 && self.groupNameTextField.text.length > 0;
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)deleteGroupButtonPressed:(id)sender {
    [self.lightController deleteGroup:self.group completion:^(NSArray *errors) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
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
