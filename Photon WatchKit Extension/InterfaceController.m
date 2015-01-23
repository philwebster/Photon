//
//  InterfaceController.m
//  Photon WatchKit Extension
//
//  Created by Philip Webster on 1/22/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "InterfaceController.h"
#import "ResourceRowController.h"


@interface InterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceTable *ResourceTable;
@property NSString *context;
@property NSArray *tableData;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.context = context;
    if ([context isEqualToString:@"Groups"]) {
        self.tableData = @[@"Group 1", @"Group 2", @"Group 3"];
    } else if ([context isEqualToString:@"Lights"]) {
        self.tableData = @[@"Light 1", @"Light 2", @"Light 3"];
    } else if ([context isEqualToString:@"Scenes"]) {
        self.tableData = @[@"Scene 1", @"Scene 2", @"Scene 3"];
    } else if ([context isEqualToString:@"ColorPicker"]) {
        self.tableData = @[ [UIColor blackColor],
                            [UIColor colorWithHue:0.626 saturation:0.871 brightness:1.000 alpha:1.000],
                            [UIColor colorWithHue:0.788 saturation:1.000 brightness:0.996 alpha:1.000],
                            [UIColor colorWithHue:0.846 saturation:1.000 brightness:0.984 alpha:1.000],
                            [UIColor colorWithHue:0.965 saturation:1.000 brightness:0.984 alpha:1.000],
                            [UIColor colorWithHue:0.081 saturation:0.881 brightness:0.992 alpha:1.000],
                            [UIColor colorWithHue:0.155 saturation:0.941 brightness:0.996 alpha:1.000],
                            [UIColor colorWithHue:0.341 saturation:0.748 brightness:1.000 alpha:1.000],
                            [UIColor colorWithHue:0.468 saturation:0.808 brightness:1.000 alpha:1.000]];

    } else {
        self.tableData = @[@"Groups", @"Lights", @"Scenes"];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self loadResourceItems];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)loadResourceItems {
    
//    NSArray* items = @[@"Groups", @"Lights", @"Scenes"];
    [self.ResourceTable setNumberOfRows:self.tableData.count withRowType:@"default"];
    NSInteger rowCount = self.ResourceTable.numberOfRows;
    
    // Iterate over the rows and set the label for each one.
    for (NSInteger i = 0; i < rowCount; i++) {
        ResourceRowController* row = [self.ResourceTable rowControllerAtIndex:i];
        if ([self.context isEqualToString:@"ColorPicker"]) {
            [row.rowGroup setBackgroundColor:[self.tableData objectAtIndex:i]];
            continue;
        }
        NSString* itemText = self.tableData[i];
        [row.resourceType setText:itemText];
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    NSLog(@"tapped row");
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
    if ([self.context isEqualToString:@"Groups"] || [self.context isEqualToString:@"Lights"]) {
        return @"ColorPicker";
    }
    return self.tableData[rowIndex];
}

@end



