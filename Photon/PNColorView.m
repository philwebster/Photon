//
//  PNColorView.m
//  Photon
//
//  Created by Philip Webster on 2/2/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNColorView.h"
#import "PNLightController.h"
#import "UIColor+PNUtilities.h"

@interface PNColorView ()

@property NSArray *colorViews;
@property BOOL isCT;
@property BOOL enableShakeGesture;

@end

@implementation PNColorView

- (id)init {
    if (self = [super init]) {
        self.isCT = YES;
        self.enableShakeGesture = NO;
    }
    return self;
}

- (void)setColors:(NSArray *)colors {
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
    }];
    self.isCT = YES;
    NSMutableArray *tempViewArray = [NSMutableArray new];
    for (int i = 0; i < colors.count; ++i) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = colors[i];
        
        [tempViewArray addObject:view];
    }
    self.colorViews = tempViewArray;
    
    CGFloat widthMultiplier = 1.0 / self.colorViews.count;
    CGFloat xMultiplier;
    CGFloat numColors = self.colorViews.count;
    
    for (int i = 0; i < numColors; ++i) {
        UIView *view = self.colorViews[i];
        xMultiplier = (1 / (numColors / 2.0)) * (i + 0.5);
        [self addSubview:view];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:xMultiplier constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    }

}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (CAGradientLayer *)gradientLayerWithColors:(NSArray *)colors {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];

    NSMutableArray *colorsCG = [NSMutableArray array];
    for (UIColor *c in colors) {
        [colorsCG addObject:(id)c.CGColor];
    }
    gradientLayer.colors = colorsCG;
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1.0, 0.5);
    return gradientLayer;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchedViewWithTouches:touches event:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint p = [(UITouch *)[touches anyObject] locationInView:self];
    UIView *updatedTouchedView = [self hitTest:p withEvent:nil];
    if (updatedTouchedView != self.touchedView) {
        self.touchedView = updatedTouchedView;
    }
}

- (void)setTouchedView:(UIView *)touchedView {
    if (_touchedView == touchedView) {
        if (!self.longPressMode) {
            _touchedView = nil;
        }
        return;
    } else {
        // TODO: This is gross
        if (touchedView) {
            if (self.isCT) {
                if ([self.colorViews containsObject:touchedView]) {
                    [self.delegate naturalColorSelected:[UIColor tempFromColor:touchedView.backgroundColor]];
                }
            } else {
                [self.delegate colorSelected:touchedView.backgroundColor];
            }
        }
    }
    _touchedView = touchedView;
}

- (void)updateTouchedViewWithTouches:(NSSet *)touches event:(UIEvent *)event {
    CGPoint p = [(UITouch *)[touches anyObject] locationInView:self];
    [self updateTouchedViewWithPoint:p];
}

- (void)updateTouchedViewWithPoint:(CGPoint)p {
    UIView *updatedTouchedView = [self hitTest:p withEvent:nil];
    self.touchedView = updatedTouchedView;
    if (!self.isFirstResponder) {
        return;
    }
}

- (NSLayoutConstraint *)widthConstraintForView:(UIView *)view {
    NSLayoutConstraint *widthConstraint;
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstItem == view && constraint.secondItem == self && constraint.firstAttribute == NSLayoutAttributeWidth) {
            widthConstraint = constraint;
            break;
        }
    }
    return widthConstraint;
}

- (NSLayoutConstraint *)heightConstraintForView:(UIView *)view {
    NSLayoutConstraint *heightConstraint;
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstItem == view && constraint.secondItem == self && constraint.firstAttribute == NSLayoutAttributeHeight) {
            heightConstraint = constraint;
            break;
        }
    }
    return heightConstraint;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
