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
//@property CAShapeLayer *shadowLayer;

@end

@implementation PNColorView

- (id)init {
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(0,0);//CGSizeMake(-15, 20);
        self.layer.shadowRadius = 2.5f;
        self.layer.shadowOpacity = 0.5f;
        //        self.layer.cornerRadius = 4.f;
        
        //        [self setColors:colors];
        
        self.gradientView = [UIView new];
        //        [self insertSubview:self.gradientView atIndex:0];
        //        self.gradLayer = [self gradientLayerWithColors:colors];
        self.gradLayer.frame = self.bounds;
        [self.gradientView.layer insertSublayer:self.gradLayer atIndex:0];
        
        //        if (colors.count == 5) {
        //            self.isCT = YES;
        //        }
        self.isCT = YES;
        self.isGradient = NO;
        self.enableShakeGesture = NO;
        [self updateShadowLayer];
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

- (void)layoutSubviews {
    // resize your layers based on the view's new bounds
    self.gradLayer.frame = self.bounds;
    [self updateShadowLayer];

// This masks the right and left sides of the color bars
//    for (UIView *view in self.colorViews) {
//        // Create a mask layer and the frame to determine what will be visible in the view.
//        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//        CGRect maskRect = CGRectMake(0,-10,view.frame.size.width,view.frame.size.height);
//        
//        // Create a path with the rectangle in it.
//        CGPathRef path = CGPathCreateWithRect(maskRect, NULL);
//        
//        // Set the path to the mask layer.
//        maskLayer.path = path;
//        maskLayer.fillRule = kCAFillRuleEvenOdd;
//        
//        // Release the path since it's not covered by ARC.
//        CGPathRelease(path);
//        
//        // Set the mask of the view.
//        view.layer.mask = maskLayer;
//    }
    
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
            [self updateShadowLayer];
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
    [self updateShadowLayer];

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

- (void)expandWidthOfView:(UIView *)view withConstraint:(NSLayoutConstraint *)constraint {
    if (!view) {
        return;
    }
    
    
//    [self updateShadowLayer];
//
//    // Set the path to the mask layer.
//    maskLayer.path = path;
//    maskLayer.fillRule = kCAFillRuleEvenOdd;
//
//    // Release the path since it's not covered by ARC.
//    CGPathRelease(path);
//
//    // Set the mask of the view.
//    self.layer.mask = maskLayer;

    
    
    
    
    [self bringSubviewToFront:view];
    CABasicAnimation *increaseRadius = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    increaseRadius.fromValue = [NSNumber numberWithFloat:0.f];
    increaseRadius.toValue = [NSNumber numberWithFloat:2.f];
    increaseRadius.duration = 0.2f;
    increaseRadius.fillMode = kCAFillModeForwards;
    increaseRadius.removedOnCompletion = YES;
    view.layer.cornerRadius = 2.f;

    
    CABasicAnimation *increaseShadowRadius = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    increaseShadowRadius.fromValue = [NSNumber numberWithFloat:0.f];
    increaseShadowRadius.toValue = [NSNumber numberWithFloat:4.5f];
    increaseShadowRadius.duration = 0.2f;
    increaseShadowRadius.fillMode = kCAFillModeForwards;
    increaseShadowRadius.removedOnCompletion = YES;
    view.layer.shadowRadius = 4.5f;
    
    CABasicAnimation *shadowOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    shadowOpacityAnimation.duration = 0.2f;
    shadowOpacityAnimation.fromValue = [NSNumber numberWithFloat:0.f];
    shadowOpacityAnimation.toValue = [NSNumber numberWithFloat:0.5f];
    shadowOpacityAnimation.fillMode = kCAFillModeBackwards;
    shadowOpacityAnimation.removedOnCompletion = YES;
    view.layer.shadowOpacity = 0.5f;
    
    CGSize loweredShadowOffset = CGSizeMake(0, 1);
    CGRect rrect = CGRectMake(view.bounds.origin.x - loweredShadowOffset.width,
                              view.bounds.origin.y + loweredShadowOffset.height,
                              view.bounds.size.width + (2 * loweredShadowOffset.width),
                              view.bounds.size.height + loweredShadowOffset.height);
    CGFloat cornerRadius = 0;
    CGPathRef startPath = [UIBezierPath bezierPathWithRoundedRect:rrect cornerRadius:cornerRadius].CGPath;
    
    CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    shadowAnimation.duration = 0.2f;
    shadowAnimation.fromValue = (__bridge id)(startPath);
    shadowAnimation.toValue = (id)[UIBezierPath bezierPathWithRoundedRect:rrect cornerRadius:2.f].CGPath;
    shadowAnimation.fillMode = kCAFillModeForwards;
    shadowAnimation.removedOnCompletion = YES;
//    view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:rrect cornerRadius:cornerRadius].CGPath;

    [view.layer addAnimation:increaseRadius forKey:@"cornerRadius"];
    [view.layer addAnimation:increaseShadowRadius forKey:@"shadowRadius"];
    [view.layer addAnimation:shadowOpacityAnimation forKey:@"shadowOpacity"];
//    [view.layer addAnimation:shadowAnimation forKey:@"shadowPath"];
//    [self updateShadowLayer];
    return;
    
    
//    [self removeConstraint:constraint];
//    CGFloat widthMultiplier = 1.18 / self.colorViews.count;
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0]];
//
//    [self removeConstraint:[self heightConstraintForView:view]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.03 constant:0]];

//    [self bringSubviewToFront:view];
//    view.layer.masksToBounds = NO;
//    view.layer.shadowOffset = CGSizeMake(2,4);//CGSizeMake(-15, 20);
//    view.layer.shadowRadius = 4.5f;
//    view.layer.shadowOpacity = 0.5f;
    [UIView animateWithDuration:2.0f animations:^{
        [self bringSubviewToFront:view];
        view.layer.masksToBounds = NO;
        view.layer.shadowOffset = CGSizeMake(2,4);//CGSizeMake(-15, 20);
        view.layer.shadowRadius = 4.5f;
        view.layer.shadowOpacity = 0.5f;
//        [self layoutIfNeeded];
    }];
}

- (void)contractWidthOfView:(UIView *)view withConstraint:(NSLayoutConstraint *)constraint {
    if (!view) {
        return;
    }
    
    CABasicAnimation *decreaseRadius = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    decreaseRadius.fromValue = [NSNumber numberWithFloat:2.f];
    decreaseRadius.toValue = [NSNumber numberWithFloat:0.f];
    decreaseRadius.duration = 0.2f;
    decreaseRadius.fillMode = kCAFillModeForwards;
    decreaseRadius.removedOnCompletion = YES;
    view.layer.cornerRadius = 0.f;
    
    CABasicAnimation *decreaseShadowRadius = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    decreaseShadowRadius.fromValue = [NSNumber numberWithFloat:4.5f];
    decreaseShadowRadius.toValue = [NSNumber numberWithFloat:0.f];
    decreaseShadowRadius.duration = 0.2f;
    decreaseShadowRadius.fillMode = kCAFillModeForwards;
    decreaseShadowRadius.removedOnCompletion = YES;
    view.layer.shadowRadius = 0.f;
    
    CABasicAnimation *shadowOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    shadowOpacityAnimation.duration = 0.2f;
    shadowOpacityAnimation.fromValue = [NSNumber numberWithFloat:0.5f];
    shadowOpacityAnimation.toValue = [NSNumber numberWithFloat:0.f];
    shadowOpacityAnimation.fillMode = kCAFillModeBackwards;
    shadowOpacityAnimation.removedOnCompletion = YES;
    view.layer.shadowOpacity = 0.f;
    
    
    CGSize loweredShadowOffset = CGSizeMake(0, 1);
    CGRect rrect = CGRectMake(view.bounds.origin.x - loweredShadowOffset.width,
                              view.bounds.origin.y + loweredShadowOffset.height,
                              view.bounds.size.width + (2 * loweredShadowOffset.width),
                              view.bounds.size.height + loweredShadowOffset.height);
    CGFloat cornerRadius = 0;
    CGPathRef startPath = [UIBezierPath bezierPathWithRoundedRect:rrect cornerRadius:2.f].CGPath;
    
    CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    shadowAnimation.duration = 0.2f;
    shadowAnimation.fromValue = (__bridge id)(startPath);
    shadowAnimation.toValue = (id)[UIBezierPath bezierPathWithRoundedRect:rrect cornerRadius:cornerRadius].CGPath;
    shadowAnimation.fillMode = kCAFillModeForwards;
    shadowAnimation.removedOnCompletion = YES;
//    view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:rrect cornerRadius:cornerRadius].CGPath;

    

    [view.layer addAnimation:decreaseRadius forKey:@"cornerRadius"];
    [view.layer addAnimation:decreaseShadowRadius forKey:@"shadowRadius"];
    [view.layer addAnimation:shadowOpacityAnimation forKey:@"shadowOpacity"];
//    [view.layer addAnimation:shadowAnimation forKey:@"shadowPath"];
//    [self updateShadowLayer];
    return;
    

//    [self removeConstraint:constraint];
//    CGFloat widthMultiplier = 1.0 / self.colorViews.count;
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0]];
//    
//    [self removeConstraint:[self heightConstraintForView:view]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];

//    view.layer.masksToBounds = YES;
//    view.layer.shadowOffset = CGSizeMake(0,0);
//    view.layer.shadowRadius = 5;
//    view.layer.shadowOpacity = 0.5;
    [UIView animateWithDuration:2.0f animations:^{
//        view.layer.masksToBounds = YES;
        view.layer.shadowOffset = CGSizeMake(0,1);
        view.layer.shadowRadius = 1.5f;
        view.layer.shadowOpacity = 0.f;
        [self sendSubviewToBack:view];
//        [self layoutIfNeeded];
    }];
}

- (void)updateShadowLayer {
//    return;
//    if (!self.shadowLayer) {
//        self.shadowLayer = [[CAShapeLayer alloc] init];
//        self.shadowLayer.shadowOffset = CGSizeMake(0,0);//CGSizeMake(-15, 20);
//        self.shadowLayer.shadowRadius = 2.5f;
//        self.shadowLayer.shadowOpacity = 0.5f;
//        self.shadowLayer.fillRule = kCAFillRuleEvenOdd;
//        [self.layer insertSublayer:self.shadowLayer atIndex:0];
//    }
    CGPathRef currentShadowPath = [self.layer.presentationLayer shadowPath];
    CGMutablePathRef p = CGPathCreateMutable();
    CGMutablePathRef wholeViewPath = CGPathCreateMutable();
    CGPathAddRect(wholeViewPath, NULL, CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)));
    if (!self.touchedView) {
        CGPathAddRect(p, NULL, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    } else {
        NSUInteger selectedIndex = [self.colorViews indexOfObject:self.touchedView];
        // path for left
        CGPathAddRect(p, NULL, CGRectMake(0, 0, selectedIndex * self.touchedView.frame.size.width, self.frame.size.height));
        // path for right
        CGPathAddRect(p, NULL, CGRectMake(self.touchedView.frame.size.width * (selectedIndex + 1), 0, (self.colorViews.count - selectedIndex - 1) * self.touchedView.frame.size.width, self.frame.size.height));
    }

    
    CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    shadowAnimation.duration = 0.1f;
    shadowAnimation.fromValue = (__bridge id)(currentShadowPath);
    shadowAnimation.toValue = (__bridge id)(p);
    shadowAnimation.fillMode = kCAFillModeForwards;
    shadowAnimation.removedOnCompletion = YES;
    shadowAnimation.beginTime = 0.1f;
    self.layer.shadowPath = p;
    [self.layer addAnimation:shadowAnimation forKey:@"shadowPath"];

//    [self setNeedsDisplay];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
