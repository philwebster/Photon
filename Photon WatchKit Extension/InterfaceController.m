//
//  InterfaceController.m
//  Photon WatchKit Extension
//
//  Created by Philip Webster on 1/22/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "InterfaceController.h"
#import "ResourceRowController.h"
#import "PTNLightController.h"

@interface InterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceTable *ResourceTable;
@property NSString *context;
@property NSArray *tableData;
@property PTNLightController *lightController;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.lightController = [PTNLightController new];
    self.context = context;
    if ([context isEqualToString:@"Groups"]) {
        self.tableData = self.lightController.groups;
    } else if ([context isEqualToString:@"Lights"]) {
        self.tableData = self.lightController.lights;
    } else if ([context isEqualToString:@"Scenes"]) {
        self.tableData = self.lightController.scenes;
    } else if ([context isEqualToString:@"ColorPicker"]) {
        self.tableData = self.lightController.standardColors;
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

    
    [self.ResourceTable setNumberOfRows:self.tableData.count withRowType:@"default"];
    NSInteger rowCount = self.ResourceTable.numberOfRows;
    
    // Iterate over the rows and set the label for each one.
    for (NSInteger i = 0; i < rowCount; i++) {
        ResourceRowController* row = [self.ResourceTable rowControllerAtIndex:i];
        if ([self.context isEqualToString:@"ColorPicker"]) {
            [row.rowGroup setBackgroundColor:[self.tableData objectAtIndex:i]];
            continue;
        }
        NSString *itemText;
        if ([self.context isEqualToString:@"Lights"]) {
            itemText = self.lightController.lights[i];
        } else if ([self.context isEqualToString:@"Groups"]) {
            itemText = self.lightController.groups[i];
        } else if ([self.context isEqualToString:@"Scenes"]) {
            itemText = self.lightController.scenes[i];
        } else {
            itemText = @"error";
        }
        
        [row.resourceType setText:itemText];
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    if ([self.context isEqualToString:@"ColorPicker"]) {

    }
    NSLog(@"tapped row");
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
    if ([self.context isEqualToString:@"Groups"] || [self.context isEqualToString:@"Lights"]) {
        return @"ColorPicker";
    }
    return self.tableData[rowIndex];
}

@end



