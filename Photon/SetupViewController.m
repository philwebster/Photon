//
//  SetupViewController.m
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "SetupViewController.h"
#import "HueBridgeView.h"
#import <HueSDK_iOS/HueSDK.h>
#import "PTNAppDelegate.h"

@interface SetupViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) HueBridgeView *bridgeView;
@property (nonatomic) float scaleFactor;
@property (nonatomic) float angle;

@end

@implementation SetupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil hueSDK:(PHHueSDK *)hueSdk delegate:(id<BridgeSetupDelegate>)delegate {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = delegate;
        self.phHueSDK = hueSdk;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [(PTNAppDelegate *)[[UIApplication sharedApplication] delegate] searchForBridgeLocal];

    _scaleFactor = 2;
    _angle = 180;

    _bridgeView = [[HueBridgeView alloc] initWithFrame:CGRectMake(50, 50, 150, 150)];
    _bridgeView.backgroundColor = [UIColor whiteColor];
    _bridgeView.hidden = YES;
//    [_bridgeView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.view addSubview:_bridgeView];
//    
//    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_bridgeView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bridgeView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
//    [_bridgeView addConstraint:[NSLayoutConstraint constraintWithItem:_bridgeView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_bridgeView attribute:NSLayoutAttributeWidth multiplier:1 constant:200]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 Starts the pushlinking process
 */
- (void)startPushLinking {
    /***************************************************
     Set up the notifications for push linkng
     *****************************************************/
    
    // Register for notifications about pushlinking
    PHNotificationManager *phNotificationMgr = [PHNotificationManager defaultManager];
    
    [phNotificationMgr registerObject:self withSelector:@selector(authenticationSuccess) forNotification:PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(authenticationFailed) forNotification:PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(noLocalConnection) forNotification:PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(noLocalBridge) forNotification:PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(buttonNotPressed:) forNotification:PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION];
    
    // Call to the hue SDK to start pushlinking process
    /***************************************************
     Call the SDK to start Push linking.
     The notifications sent by the SDK will confirm success
     or failure of push linking
     *****************************************************/
    self.instructionLabel.text = @"Push the button";
    _bridgeView.hidden = NO;
    self.progressView.hidden = NO;
    [self.phHueSDK startPushlinkAuthentication];
}

/**
 Notification receiver which is called when the pushlinking was successful
 */
- (void)authenticationSuccess {
    /***************************************************
     The notification PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION
     was received. We have confirmed the bridge.
     De-register for notifications and call
     pushLinkSuccess on the delegate
     *****************************************************/
    // Deregister for all notifications
    [[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
    
    // Inform delegate
    [self.delegate pushlinkSuccess];
    self.instructionLabel.text = @"";
}

/**
 Notification receiver which is called when the pushlinking failed because the time limit was reached
 */
- (void)authenticationFailed {
    // Deregister for all notifications
    [[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
    
    // Inform delegate
    [self.delegate pushlinkFailed:[PHError errorWithDomain:SDK_ERROR_DOMAIN
                                                      code:PUSHLINK_TIME_LIMIT_REACHED
                                                  userInfo:[NSDictionary dictionaryWithObject:@"Authentication failed: time limit reached." forKey:NSLocalizedDescriptionKey]]];
}

/**
 Notification receiver which is called when the pushlinking failed because the local connection to the bridge was lost
 */
- (void)noLocalConnection {
    // Deregister for all notifications
    [[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
    
    // Inform delegate
    [self.delegate pushlinkFailed:[PHError errorWithDomain:SDK_ERROR_DOMAIN
                                                      code:PUSHLINK_NO_CONNECTION
                                                  userInfo:[NSDictionary dictionaryWithObject:@"Authentication failed: No local connection to bridge." forKey:NSLocalizedDescriptionKey]]];
}

/**
 Notification receiver which is called when the pushlinking failed because we do not know the address of the local bridge
 */
- (void)noLocalBridge {
    // Deregister for all notifications
    [[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
    
    // Inform delegate
    [self.delegate pushlinkFailed:[PHError errorWithDomain:SDK_ERROR_DOMAIN code:PUSHLINK_NO_LOCAL_BRIDGE userInfo:[NSDictionary dictionaryWithObject:@"Authentication failed: No local bridge found." forKey:NSLocalizedDescriptionKey]]];
}

/**
 This method is called when the pushlinking is still ongoing but no button was pressed yet.
 @param notification The notification which contains the pushlinking percentage which has passed.
 */
- (void)buttonNotPressed:(NSNotification *)notification {
    // Update status bar with percentage from notification
    NSDictionary *dict = notification.userInfo;
    NSNumber *progressPercentage = [dict objectForKey:@"progressPercentage"];
    
    // Convert percentage to the progressbar scale
    float progressBarValue = [progressPercentage floatValue] / 100.0f;
    self.progressView.progress = progressBarValue;
}

- (void)setMultipleBridgesFound:(NSDictionary *)bridges {
    self.bridges = bridges;
    [self.tableView reloadData];
    self.tableView.hidden = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bridges.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Sort bridges by mac address
    NSArray *sortedKeys = [self.bridges.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    // Get mac address and ip address of selected bridge
    NSString *mac = [sortedKeys objectAtIndex:indexPath.row];
    NSString *ip = [self.bridges objectForKey:mac];
    
    // Update cell
    cell.textLabel.text = mac;
    cell.detailTextLabel.text = ip;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sortedKeys = [self.bridges.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSString *mac = [sortedKeys objectAtIndex:indexPath.row];
    NSString *ip = [self.bridges objectForKey:mac];
    [(PTNAppDelegate *)[[UIApplication sharedApplication] delegate] bridgeSelectedWithIpAddress:ip andMacAddress:mac];
}

- (IBAction)continueButtonPressed:(id)sender {
    ((PTNAppDelegate *)[[UIApplication sharedApplication] delegate]).inDemoMode = YES;
    [self authenticationSuccess];
}

@end
