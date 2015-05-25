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

@property (nonatomic, strong) UIView *touchedView;
@property id <colorSelectionDelegate> delegate;
@property BOOL longPressMode;

- (void)updateTouchedViewWithPoint:(CGPoint)p;
- (void)setColors:(NSArray *)colors;

@end
