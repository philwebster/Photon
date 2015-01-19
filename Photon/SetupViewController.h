//
//  SetupViewController.h
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHHueSDK;
@class PHError;

/**
 Delegate protocol for this bridge pushlink viewcontroller
 */
@protocol BridgeSetupDelegate <NSObject>

@required

/**
 Method which is invoked when the pushlinking was successful
 */
- (void)pushlinkSuccess;

/**
 Method which is invoked when the pushlinking failed
 @param error The error which caused the pushlinking to fail
 */
- (void)pushlinkFailed:(PHError *)error;

@end


@interface SetupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) PHHueSDK *phHueSDK;
@property (nonatomic, unsafe_unretained) id<BridgeSetupDelegate> delegate;
@property (nonatomic, strong) NSDictionary *bridges;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil hueSDK:(PHHueSDK *)hueSdk delegate:(id<BridgeSetupDelegate>)delegate;
- (void)setMultipleBridgesFound:(NSDictionary *)bridges;
- (void)startPushLinking;

@end
