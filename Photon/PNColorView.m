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
@property UIView *touchedView;
@property UIView *gradientView;
@property CAGradientLayer *gradLayer;
@property BOOL isCT;

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
        [self addSubview:self.gradientView];
        self.gradLayer = [self gradientLayerWithColors:colors];
        self.gradLayer.frame = self.bounds;
        [self.gradientView.layer insertSublayer:self.gradLayer atIndex:0];
        
        if (colors.count == 5) {
            self.isCT = YES;
        }
        
        [self becomeFirstResponder];
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
    if (event.subtype == UIEventSubtypeMotionShake) {
        [UIView animateWithDuration:0.25 animations:^() {
            self.gradientView.alpha = self.gradientView.alpha == 0.0f ? 1.0f : 0.0f;
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchedViewWithTouches:touches event:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchedViewWithTouches:touches event:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint p = [(UITouch *)[touches anyObject] locationInView:self];
    UIView *updatedTouchedView = [self hitTest:p withEvent:event];
    updatedTouchedView.layer.borderWidth = 0;
    _touchedView = nil;
}

- (void)updateTouchedViewWithTouches:(NSSet *)touches event:(UIEvent *)event {
    CGPoint p = [(UITouch *)[touches anyObject] locationInView:self];
    UIView *updatedTouchedView = [self hitTest:p withEvent:event];
    if (_touchedView == updatedTouchedView || !self.isFirstResponder) {
        return;
    }
    updatedTouchedView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    updatedTouchedView.layer.borderWidth = 4;

    _touchedView.layer.borderWidth = 0;
    _touchedView = updatedTouchedView;
    
    // TODO: Fire a timer and set the color if it's still being touched after a second or so
    if (self.isCT) {
        [self.delegate naturalColorSelected:[UIColor tempFromColor:_touchedView.backgroundColor]];
    } else {
        [self.delegate colorSelected:_touchedView.backgroundColor];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
