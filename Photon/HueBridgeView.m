//
//  HueBridgeView.m
//  Photon
//
//  Created by Philip Webster on 1/19/15.
//  Copyright (c) 2015 phil. All rights reserved.
//

#import "HueBridgeView.h"

@implementation HueBridgeView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
//    // Drawing code
//    UIBezierPath *aPath = [UIBezierPath bezierPath];
//    
//    // Set the starting point of the shape.
////    [aPath moveToPoint:CGPointMake(self.frame.size.width, self.frame.size.height / 2)];
//    
//    // Draw the lines.
//    [aPath addArcWithCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2) radius:self.frame.size.width - 10 startAngle:0 endAngle:M_2_PI clockwise:YES];
//    [aPath stroke];
//
//
    UIBezierPath *aPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.frame.size.width - 20, self.frame.size.height - 20)];
    
    // Set the render colors.
    [[UIColor lightGrayColor] setStroke];
    [[UIColor whiteColor] setFill];
    
    CGContextRef aRef = UIGraphicsGetCurrentContext();
    
    // If you have content to draw after the shape,
    // save the current state before changing the transform.
    //CGContextSaveGState(aRef);
    
    // Adjust the view's origin temporarily. The oval is
    // now drawn relative to the new origin point.
    CGContextTranslateCTM(aRef, 10, 10);
    
    // Adjust the drawing options as needed.
    aPath.lineWidth = 3;
    
    // Fill the path before stroking it so that the fill
    // color does not obscure the stroked line.
    [aPath fill];
    [aPath stroke];
    
    // Restore the graphics state before drawing any other content.
    //CGContextRestoreGState(aRef);

    
}


@end
