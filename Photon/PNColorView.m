//
//  PNColorView.m
//  Photon
//
//  Created by Philip Webster on 2/2/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNColorView.h"
#import "PNLightController.h"

@interface PNColorView ()

@property NSArray *colorViews;

@end

@implementation PNColorView

- (id)initWithFrame:(CGRect)frame colors:(NSArray *)colors {
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
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
