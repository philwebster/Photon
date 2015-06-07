//
//  PNCardView.m
//  Photon
//
//  Created by Philip Webster on 6/3/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "PNCardView.h"

@implementation PNCardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init {
    if (self = [super init]) {
        [self setupCard];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupCard];
    }
    return self;
}

- (void)setupCard {
    self.layer.cornerRadius = 4;
    
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0,0);//CGSizeMake(-15, 20);
    self.layer.shadowRadius = 2.5f;
    self.layer.shadowOpacity = 0.5f;
    self.clipsToBounds = YES;
}
@end
