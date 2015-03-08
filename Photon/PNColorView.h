//
//  PNColorView.h
//  Photon
//
//  Created by Philip Webster on 2/2/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol colorSelectionDelegate

- (void)colorSelected:(UIColor *)color;
- (void)naturalColorSelected:(NSNumber *)colorTemp;

@end

@interface PNColorView : UIView

@property id <colorSelectionDelegate> delegate;
@property BOOL longPressMode;

- (id)initWithFrame:(CGRect)frame colors:(NSArray *)colors;
- (void)updateTouchedViewWithPoint:(CGPoint)p;

@end
