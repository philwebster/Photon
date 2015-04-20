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
@property UIView *gradientView;
@property CAGradientLayer *gradLayer;
@property BOOL isCT;
@property BOOL isGradient;
@property BOOL enableShakeGesture;

@end

@implementation PNColorView

- (id)initWithFrame:(CGRect)frame colors:(NSArray *)colors {
    // TODO: Pass in a gradient
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
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
        
        self.gradientView = [UIView new];
        [self insertSubview:self.gradientView atIndex:0];
        self.gradLayer = [self gradientLayerWithColors:colors];
        self.gradLayer.frame = self.bounds;
        [self.gradientView.layer insertSublayer:self.gradLayer atIndex:0];
        
        if (colors.count == 5) {
            self.isCT = YES;
        }
        self.isGradient = NO;
        self.enableShakeGesture = NO;
        
        self.layer.cornerRadius = 9;
        
        self.layer.masksToBounds = NO;
    }
    return self;
}

- (void)layoutSubviews {
    // resize your layers based on the view's new bounds
    self.gradLayer.frame = self.bounds;
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

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.subtype == UIEventSubtypeMotionShake && self.enableShakeGesture) {
        self.isGradient = !self.isGradient;
        [UIView animateWithDuration:0.25 animations:^() {
            [self bringSubviewToFront:self.gradientView];
            self.gradientView.alpha = self.isGradient ? 1.0f : 0.0f;
        }];
    }
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
            [self contractWidthOfView:_touchedView withConstraint:[self widthConstraintForView:_touchedView]];
            _touchedView = nil;
        }
        return;
    } else {
        // TODO: This is gross
        if (touchedView) {
            if (self.isCT) {
                if (self.isGradient) {
                    [self.delegate naturalColorSelected:[NSNumber numberWithInt:300]];
                } else if ([self.colorViews containsObject:touchedView]) {
                    [self.delegate naturalColorSelected:[UIColor tempFromColor:touchedView.backgroundColor]];
                }
            } else {
                [self.delegate colorSelected:touchedView.backgroundColor];
            }
            [self expandWidthOfView:touchedView withConstraint:[self widthConstraintForView:touchedView]];
        }
        [self contractWidthOfView:_touchedView withConstraint:[self widthConstraintForView:_touchedView]];
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

- (void)expandWidthOfView:(UIView *)view withConstraint:(NSLayoutConstraint *)constraint {
    if (!view) {
        return;
    }
    [self removeConstraint:constraint];
    CGFloat widthMultiplier = 1.3 / self.colorViews.count;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0]];
    [self bringSubviewToFront:view];

    view.layer.masksToBounds = NO;
    view.layer.shadowOffset = CGSizeMake(0,0);//CGSizeMake(-15, 20);
    view.layer.shadowRadius = 5;
    view.layer.shadowOpacity = 0.5;
    [UIView animateWithDuration:0.05 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)contractWidthOfView:(UIView *)view withConstraint:(NSLayoutConstraint *)constraint {
    if (!view) {
        return;
    }
    [self removeConstraint:constraint];
    CGFloat widthMultiplier = 1.0 / self.colorViews.count;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0]];
    view.layer.masksToBounds = YES;
    view.layer.shadowOffset = CGSizeMake(0,0);//CGSizeMake(-15, 20);
    view.layer.shadowRadius = 5;
    view.layer.shadowOpacity = 0.5;
    [UIView animateWithDuration:0.05 animations:^{
        [self layoutIfNeeded];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
