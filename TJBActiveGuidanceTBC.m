//
//  TJBActiveGuidanceTBC.m
//  Beast
//
//  Created by Trevor Beasty on 4/19/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBActiveGuidanceTBC.h"

#import "CoreDataController.h" // core data

#import "TJBActiveRoutineGuidanceVC.h" // active guidance main scene
#import "TJBWorkoutNavigationHub.h" // workout log
#import "TJBActiveGuidanceTargetsScene.h" // routine targets
#import "TJBActiveGuidanceRoutineHistory.h" // routine history

#import "TJBAestheticsController.h" // aesthetics


@interface TJBActiveGuidanceTBC ()

// core

@property (strong) TJBChainTemplate *chainTemplate;

@end

@implementation TJBActiveGuidanceTBC


#pragma mark - Instantiation

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)ct{
    
    self = [super init];
    
    if (self){
        
        self.chainTemplate = ct;
        
        [self configureTabBarController];
        
    }
    
    return self;
    
}


#pragma mark - Init Helper Methods

- (void)configureTabBarController{
    
    TJBActiveRoutineGuidanceVC *vc1 = [[TJBActiveRoutineGuidanceVC alloc] initFreshRoutineWithChainTemplate: self.chainTemplate];
    
    TJBActiveGuidanceTargetsScene *vc2 = [[TJBActiveGuidanceTargetsScene alloc] initWithChainTemplate: self.chainTemplate];
    
    TJBActiveGuidanceRoutineHistory *vc3 = [[TJBActiveGuidanceRoutineHistory alloc] initWithChainTemplate: self.chainTemplate];
    
    TJBWorkoutNavigationHub *vc4 = [[TJBWorkoutNavigationHub alloc] initWithHomeButton: NO
                                                                advancedControlsActive: NO];
    vc4.tabBarItem.title = @"Workout Log";
    vc4.tabBarItem.image = [UIImage imageNamed: @"workoutLog"];
    

    [self setViewControllers: @[vc1, vc2, vc3, vc4]];
    self.tabBar.translucent = NO;
    self.tabBar.barTintColor = [UIColor darkGrayColor];
    self.tabBar.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    
}



@end


















