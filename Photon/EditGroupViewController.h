//
//  EditGroupViewController.h
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHGroup;

@interface EditGroupViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (id)initWithGroup:(PHGroup *)group;

@end
