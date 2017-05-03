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


@interface TJBActiveGuidanceTBC () <UIViewControllerRestoration>

@end



#pragma mark - Constants

static NSString * const restorationID = @"TJBActiveGuidanceTBC";
static NSString * const activeSceneKey = @"ActiveScene";
static NSString * const targetsSceneKey = @"TargetsScene";
static NSString * const historySceneKey = @"HistoryScene";
static NSString * const workoutLogKey = @"WorkoutLog";
static NSString * const selectedIndexKey = @"SelectedIndex";


@implementation TJBActiveGuidanceTBC


#pragma mark - Instantiation

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)ct{
    
    self = [super init];
    
    if (self){
        
        [self configureProperties];
        
        [self configureChildControllersForChainTemplate: ct];
        
        [self configureRestorationProperties];
        
    }
    
    return self;
    
}

- (instancetype)initForRestoration{
    
    self = [super init];
    
    
    [self configureProperties];
    
    [self configureRestorationProperties];
    
    return self;
    
}


#pragma mark - Init Helper Methods

- (void)configureProperties{
    
    self.tabBar.barTintColor = [UIColor darkGrayColor];
    self.tabBar.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    self.tabBar.translucent = NO;
    
}

- (void)configureChildControllersForChainTemplate:(TJBChainTemplate *)ct{
    
    TJBActiveRoutineGuidanceVC *vc1 = [[TJBActiveRoutineGuidanceVC alloc] initFreshRoutineWithChainTemplate: ct];
    
    TJBActiveGuidanceTargetsScene *vc2 = [[TJBActiveGuidanceTargetsScene alloc] initWithChainTemplate: ct];
    
    TJBActiveGuidanceRoutineHistory *vc3 = [[TJBActiveGuidanceRoutineHistory alloc] initWithChainTemplate: ct];
    
    TJBWorkoutNavigationHub *vc4 = [[TJBWorkoutNavigationHub alloc] initWithHomeButton: NO
                                                                advancedControlsActive: NO];

    [self setViewControllers: @[vc1, vc2, vc3, vc4]];

    
}

- (void)configureRestorationProperties{
    
    self.restorationIdentifier = restorationID;
    self.restorationClass = [TJBActiveGuidanceTBC class];
    
    
}


#pragma mark - Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super encodeRestorableStateWithCoder: coder];
    
    [coder encodeObject: self.viewControllers[0]
                 forKey: activeSceneKey];
    [coder encodeObject: self.viewControllers[1]
                 forKey: targetsSceneKey];
    [coder encodeObject: self.viewControllers[2]
                 forKey: historySceneKey];
    [coder encodeObject: self.viewControllers[3]
                 forKey: workoutLogKey];
    
    [coder encodeInteger: self.selectedIndex
                  forKey: selectedIndexKey];
    
}

+(UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    return [[TJBActiveGuidanceTBC alloc] initForRestoration];
    
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    
    TJBActiveRoutineGuidanceVC *activeGuidanceVC = [coder decodeObjectForKey: activeSceneKey];
    TJBActiveGuidanceTargetsScene *targetsVC = [coder decodeObjectForKey: targetsSceneKey];
    TJBActiveGuidanceRoutineHistory *historyVC = [coder decodeObjectForKey: historySceneKey];
    TJBWorkoutNavigationHub *workoutLog = [coder decodeObjectForKey: workoutLogKey];
    
    [self setViewControllers: @[activeGuidanceVC, targetsVC, historyVC, workoutLog]];
    
    self.selectedIndex = [coder decodeIntegerForKey: selectedIndexKey];
    
}




@end


















