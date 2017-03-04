//
//  TJBRoutineSelectionTBC.m
//  Beast
//
//  Created by Trevor Beasty on 3/4/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBRoutineSelectionTBC.h"

// child vc's

#import "NewOrExistinigCircuitVC.h"
#import "TJBWorkoutNavigationHub.h"

@interface TJBRoutineSelectionTBC () <UITabBarControllerDelegate>

@end

@implementation TJBRoutineSelectionTBC

#pragma mark - Instantiation

- (instancetype)init{
    
    self = [super init];
    
    if (self){
        
        NewOrExistinigCircuitVC *vc1 = [[NewOrExistinigCircuitVC alloc] init];
        vc1.tabBarItem.title = @"Selection";
        
        TJBWorkoutNavigationHub *vc2 = [[TJBWorkoutNavigationHub alloc] initWithHomeButton: NO];
        vc2.tabBarItem.title = @"Workout Log";
    
        [self setViewControllers: @[vc1, vc2]];
        self.tabBar.translucent = NO;
        
    }

    return self;
    
}

#pragma mark - <UITabBarControllerDelegate>

//- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
//    
//    // if the workout log was selected, have the routine selection vc write a block to restore its selection state when it reappears
//    
//    // workout log was selected
//    
//    if ([viewController isEqual: self.viewControllers[1]]){
//        
//        NewOrExistinigCircuitVC *routineSelectionVC = self.viewControllers[0];
//        
//        [routineSelectionVC willDisplayWorkoutLog];
//        
//    }
//    
//    // routine selection was selected
//    
//    if ([viewController isEqual: self.viewControllers[0]]){
//        
//        
//        
//    }
//    
//}

@end
