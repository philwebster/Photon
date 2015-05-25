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
@property (weak) IBOutlet NSButton *loopButton;
@property (weak, nonatomic) PNLightController *lightController;
@property NSTimer *loopTimer;

@end

@implementation PNResourceVC

@synthesize resources;
@synthesize selection;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self setResources:[[[PNLightController singleton] groups] mutableCopy]];
    self.lightController = [PNLightController singleton];
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

- (void)setSelection:(NSIndexSet *)s {
    selection = s;
    NSLog(@"selection: %@", selection);
}

- (NSIndexSet *)selection {
    return selection;
}

- (IBAction)loopPressed:(id)sender {
    if ([self.loopButton.title isEqualToString:@"Stop the loopage"]) {
        [self.loopTimer invalidate];
        self.loopButton.title = @"Loop me";
    } else if (selection.count > 0) {
        NSInteger transition = 120;
        [self.lightController startColorLoopForResource:[self.lightController.groups objectAtIndex:selection.firstIndex] transitionTime:transition];
        self.loopTimer = [NSTimer scheduledTimerWithTimeInterval:transition target:self.lightController selector:@selector(stepColorLoop) userInfo:nil repeats:YES];
        self.loopButton.title = @"Stop the loopage";
    }
}

//- (void)step {
//    [self.lightController stepColorLoopCompletion:nil];
//}

@end
