//
//  TJBCircleView.m
//  Beast
//
//  Created by Trevor Beasty on 1/26/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircleView.h"

@implementation TJBCircleView

- (void)drawRect:(CGRect)rect{
    
    // establish the bezier path
    
    CGRect frame = self.frame;
    
    CGPoint center = CGPointMake( frame.size.width / 2.0,  frame.size.height / 2.0);
    
    CGFloat radius;
    
    if (frame.size.width > frame.size.height){
        
        radius = frame.size.height / 2.0;
        
    } else{
        
        radius = frame.size.width / 2.0;
        
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter: center
                                                        radius: radius
                                                    startAngle: 0
                                                      endAngle: 2 * M_PI
                                                     clockwise: YES];
    
    // set the color and draw the path
    
    [[UIColor darkGrayColor] set];
    
    [path stroke];
    
}

@end
