//
//  PNResourceVC.m
//  Photon
//
//  Created by Philip Webster on 5/24/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNResourceVC.h"
#import "PNLightController.h"
#import "PNResourceCollectionView.h"

@interface PNResourceVC ()

@property (weak) IBOutlet PNResourceCollectionView *resourceCollectionView;

@end

@implementation PNResourceVC
@synthesize resources;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self setResources:[[[PNLightController singleton] groups] mutableCopy]];

}

-(void)insertObject:(PHBridgeResource *)r inResourcesAtIndex:(NSUInteger)index {
    [resources insertObject:r atIndex:index];
}

-(void)removeObjectFromResourcesAtIndex:(NSUInteger)index {
    [resources removeObjectAtIndex:index];
}

-(void)setResources:(NSMutableArray *)a {
    resources = a;
}

-(NSArray*)resources {
    return resources;
}


@end
