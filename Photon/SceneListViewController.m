//
//  SceneListViewController.m
//  Photon
//
//  Created by Philip Webster on 2/1/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "SceneListViewController.h"
#import "PNAppDelegate.h"
#import <HueSDK_iOS/HueSDK.h>

@interface SceneListViewController ()

@property UITableView *sceneTableView;
@property UIBarButtonItem *createSceneButton;

@end

@implementation SceneListViewController

- (id)init {
    self = [super init];
    if (self) {
        self.sceneTableView = [[UITableView alloc] initWithFrame:self.view.frame];
        self.sceneTableView.dataSource = self;
        self.sceneTableView.delegate = self;
        self.sceneTableView.allowsMultipleSelectionDuringEditing = YES;
        [self.view addSubview:self.sceneTableView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.createSceneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createScene)];
    self.navigationItem.rightBarButtonItem = self.createSceneButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[[PHBridgeResourcesReader readBridgeResourcesCache] scenes] allValues] count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSArray *scenes = [[[PHBridgeResourcesReader readBridgeResourcesCache] scenes] allValues];
    cell.textLabel.text = [scenes[indexPath.row] name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)createScene {

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
