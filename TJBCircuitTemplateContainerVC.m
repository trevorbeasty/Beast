//
//  TJBCircuitTemplateContainerVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitTemplateContainerVC.h"

#import "TJBCircuitTemplateVC.h"

@interface TJBCircuitTemplateContainerVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation TJBCircuitTemplateContainerVC

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    
    float viewHeightAsFloat = self.containerView.bounds.size.height;
    float viewWidthAsFloat = self.containerView.bounds.size.width;
    
    NSNumber *viewHeight = [NSNumber numberWithFloat: viewHeightAsFloat];
    NSNumber *viewWidth = [NSNumber numberWithFloat: viewWidthAsFloat];
    
    TJBCircuitTemplateVC *vc = [[TJBCircuitTemplateVC alloc] initWithTargetingWeight: [NSNumber numberWithBool: YES]
                                                                       targetingReps: [NSNumber numberWithBool: YES]
                                                                       targetingRest: [NSNumber numberWithBool: YES]
                                                                  targetsVaryByRound: [NSNumber numberWithBool: YES]
                                                                   numberOfExercises: [NSNumber numberWithInt: 6]
                                                                      numberOfRounds: [NSNumber numberWithInt: 5]
                                                                                name: @"test template"
                                                                          viewHeight: viewHeight
                                                                           viewWidth: viewWidth];
    
    [self.containerView addSubview: vc.view];
}


@end
