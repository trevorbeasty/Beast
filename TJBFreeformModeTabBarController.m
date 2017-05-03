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

// restoration

static NSString * const restorationID = @"TJBFreeformModeTabBarController";

static NSString * const activeEntryID = @"TJBRealizedSetActiveEntryVC";
static NSString * const personalRecordsID = @"TJBPersonalRecordsVC";
static NSString * const exerciseHistoryVC = @"TJBExerciseHistoryVC";
static NSString * const workoutLogID = @"TJBWorkoutNavigationHub";
static NSString * const selectedTabIndexID = @"selectedTabIndexID";



@implementation TJBFreeformModeTabBarController


#pragma mark - Instantiation

- (instancetype)init{
    
    return [self initWithActiveExercise: nil];
    
}

- (instancetype)initWithActiveExercise:(TJBExercise *)exercise{
    
    self = [super init];
    
    
    [self configureChildViewControllersWithActiveExercise: exercise];
    [self configureProperties];
    [self setRestorationProperties];
    
    
    return self;
    
}

- (instancetype)initForRestoration{
    
    self = [super init];
    
    
    [self configureProperties];
    [self setRestorationProperties];
    
    
    return self;
    
}


#pragma mark - Instantiation Helper Methods

- (void)setRestorationProperties{
    
    self.restorationIdentifier = restorationID;
    self.restorationClass = [TJBFreeformModeTabBarController class];
    
}

- (void)configureChildViewControllersWithActiveExercise:(TJBExercise *)exercise{
    
    // tab bar vc's
    
    TJBRealizedSetActiveEntryVC *vc1;
    
    if (exercise){
        
        vc1 = [[TJBRealizedSetActiveEntryVC alloc] initWithActiveExercise: exercise];
        
    } else{
        
        vc1 = [[TJBRealizedSetActiveEntryVC alloc] init];
        
    }
 
    TJBPersonalRecordVC <TJBPersonalRecordsVCProtocol> *vc2 = [[TJBPersonalRecordVC alloc] init];
    [vc1 configureSiblingPersonalRecordsVC: vc2];
    
    TJBExerciseHistoryVC <TJBExerciseHistoryProtocol> *vc3 = [[TJBExerciseHistoryVC alloc] init];
    [vc1 configureSiblingExerciseHistoryVC: vc3];
    
    TJBWorkoutNavigationHub *vc4 = [[TJBWorkoutNavigationHub alloc] initWithHomeButton: NO
                                                                advancedControlsActive: YES];
    
    if (exercise){
        
        [vc2 activeExerciseDidUpdate: exercise];
        [vc3 activeExerciseDidUpdate: exercise];
        
    }
    
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
    
    [super encodeRestorableStateWithCoder: coder];
    
    NSArray *childVCs = self.viewControllers;
    
    [coder encodeObject: childVCs[0]
                 forKey: activeEntryID];
    
    [coder encodeObject: childVCs[1]
                 forKey: personalRecordsID];
    
    [coder encodeObject: childVCs[2]
                 forKey: exerciseHistoryVC];
    
    [coder encodeObject: childVCs[3]
                 forKey: workoutLogID];
    
    [coder encodeObject: @(self.selectedIndex)
                 forKey: selectedTabIndexID];
    
}

+(UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    
    TJBFreeformModeTabBarController *tbc = [[TJBFreeformModeTabBarController alloc] initForRestoration];
    
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
    
    NSNumber *selectedItemIndex = [coder decodeObjectForKey: selectedTabIndexID];
    self.selectedIndex = [selectedItemIndex integerValue];
    
    return;
    
    
}


@end










































