//
//  TJBFreeformModeTabBarController.m
//  Beast
//
//  Created by Trevor Beasty on 4/26/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBFreeformModeTabBarController.h"

#import "TJBRealizedSetActiveEntryVC.h" // central freefrom lift child VC
#import "TJBPersonalRecordVC.h" // personal records child VC
#import "TJBPersonalRecordsVCProtocol.h"
#import "TJBExerciseHistoryVC.h" // exercise history child VC
#import "TJBExerciseHistoryProtocol.h"
#import "TJBWorkoutNavigationHub.h" // workout log child VC

#import "TJBAestheticsController.h" // aesthetics

@interface TJBFreeformModeTabBarController () <UIViewControllerRestoration>

@end




#pragma mark - Constants

static NSString * const restorationID = @"TJBFreeformModeTabBarController";

static NSString * const activeEntryID = @"TJBRealizedSetActiveEntryVC";
static NSString * const personalRecordsID = @"TJBPersonalRecordsVC";
static NSString * const exerciseHistoryVC = @"TJBExerciseHistoryVC";
static NSString * const workoutLogID = @"TJBWorkoutNavigationHub";




@implementation TJBFreeformModeTabBarController


#pragma mark - Instantiation

- (instancetype)init{
    
    self = [super init];
    
    
    [self configureChildViewControllers];
    [self configureProperties];
    
    
    return self;
    
}




#pragma mark - Instantiation Helper Methods

- (void)setRestorationProperties{
    
    self.restorationIdentifier = restorationID;
    self.restorationClass = [TJBFreeformModeTabBarController class];
    
}

- (void)configureChildViewControllers{
    
    // tab bar vc's
    
    TJBRealizedSetActiveEntryVC *vc1 = [[TJBRealizedSetActiveEntryVC alloc] init];
    vc1.tabBarItem.title = @"Active";
    vc1.tabBarItem.image = [UIImage imageNamed: @"activeLift"];
    
    TJBPersonalRecordVC <TJBPersonalRecordsVCProtocol> *vc2 = [[TJBPersonalRecordVC alloc] init];
    vc2.tabBarItem.title = @"PR's";
    vc2.tabBarItem.image = [UIImage imageNamed: @"trophyBlue25"];
    [vc1 configureSiblingPersonalRecordsVC: vc2];
    
    TJBExerciseHistoryVC <TJBExerciseHistoryProtocol> *vc3 = [[TJBExerciseHistoryVC alloc] init];
    vc3.tabBarItem.title = @"History";
    vc3.tabBarItem.image = [UIImage imageNamed: @"colosseumBlue25"];
    [vc1 configureSiblingExerciseHistoryVC: vc3];
    
    TJBWorkoutNavigationHub *vc4 = [[TJBWorkoutNavigationHub alloc] initWithHomeButton: NO
                                                                advancedControlsActive: YES];
    vc4.tabBarItem.title = @"Workout Log";
    vc4.tabBarItem.image = [UIImage imageNamed: @"workoutLog"];
    
    // tab bar controller
    
    [self setViewControllers: @[vc1, vc2, vc3, vc4]];

    
}

- (void)configureProperties{
    
    self.tabBar.translucent = NO;
    self.tabBar.barTintColor = [UIColor darkGrayColor];
    self.tabBar.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    
}


#pragma mark - Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    NSArray *childVCs = self.viewControllers;
    
    [coder encodeObject: childVCs[0]
                 forKey: activeEntryID];
    
    [coder encodeObject: childVCs[1]
                 forKey: personalRecordsID];
    
    [coder encodeObject: childVCs[2]
                 forKey: exerciseHistoryVC];
    
    [coder encodeObject: childVCs[3]
                 forKey: workoutLogID];
    
}

+(UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    TJBFreeformModeTabBarController *tbc = [[TJBFreeformModeTabBarController alloc] init];
    
    return tbc;
    
}


- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    
    TJBRealizedSetActiveEntryVC *activeEntry = [coder decodeObjectForKey: activeEntryID];
    TJBPersonalRecordVC *personalRecords = [coder decodeObjectForKey: personalRecordsID];
    TJBExerciseHistoryVC *exerciseHistory = [coder decodeObjectForKey: exerciseHistoryVC];
    TJBWorkoutNavigationHub *navigationHub = [coder decodeObjectForKey: workoutLogID];
    
    // relationships between child VC's
    
    [activeEntry configureSiblingPersonalRecordsVC: personalRecords];
    [activeEntry configureSiblingExerciseHistoryVC: exerciseHistory];
    
    [self setViewControllers: @[activeEntry, personalRecords, exerciseHistory, navigationHub]];
    
    [self configureProperties];
    [self setRestorationProperties];
    
}


@end










































