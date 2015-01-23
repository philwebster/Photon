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

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self loadResourceItems];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)loadResourceItems {
    // Fetch the to-do items
    NSArray* items = @[@"hello", @"hi", @"bye"];//  [self fetchTodoList];
    
    // Configure the table object (self.todoItems) and get the row controllers.
    [self.ResourceTable setNumberOfRows:items.count withRowType:@"default"];
    NSInteger rowCount = self.ResourceTable.numberOfRows;
    
    // Iterate over the rows and set the label for each one.
    for (NSInteger i = 0; i < rowCount; i++) {
        // Get the to-do item data.
        NSString* itemText = items[i];
        
        // Assign the text to the row's label.
        ResourceRowController* row = [self.ResourceTable rowControllerAtIndex:i];
        [row.resourceType setText:itemText];
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    NSLog(@"tapped row");
}

@end



