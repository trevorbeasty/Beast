//
//  TJBCircuitModeTBC.m
//  Beast
//
//  Created by Trevor Beasty on 1/8/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitModeTBC.h"

// child VC's

#import "TJBActiveCircuitGuidance.h"
#import "TJBCircuitReferenceContainerVC.h"
#import "TJBCircuitActiveUpdatingContainerVC.h"
#import "RealizedSetPersonalRecordVC.h"

// protocols

//#import "TJBCircuitActiveUpdatingVCProtocol.h"
#import "SelectedExerciseObserver.h"

// core data

#import "CoreDataController.h"

@interface TJBCircuitModeTBC () <UIViewControllerRestoration>

@end

@implementation TJBCircuitModeTBC

#pragma mark - Instantiation

- (instancetype)initWithNewRealizedChainAndChainTemplateFromChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    self = [super init];
    
    // create a skeleton realized chain from the chainTemplate parameter
    // all tab bar child VC's will be configured using these two objects
    
    TJBRealizedChain *realizedChainSkeleton = [[CoreDataController singleton] createAndSaveSkeletonRealizedChainForChainTemplate: chainTemplate];
    
    //// circuit active updating container VC
    // view must be loaded before 'active guidance' VC is created, otherwise child VC will not have been instantiated and stored as accessible property
    
    TJBCircuitActiveUpdatingContainerVC *circuitActiveUpdating = [[TJBCircuitActiveUpdatingContainerVC alloc] initWithRealizedChain: realizedChainSkeleton];
    
    [circuitActiveUpdating loadViewIfNeeded];
    
    [circuitActiveUpdating.tabBarItem setTitle: @"Progress"];
    
    // personal records VC
    
    RealizedSetPersonalRecordVC *personalRecordsVC = [[RealizedSetPersonalRecordVC alloc] init];
    
    [personalRecordsVC.tabBarItem setTitle: @"Records"];
    
    // active circuit guidance VC - must be instantiated after circuit active updating because the latter VC is required as a parameter
    
    TJBActiveCircuitGuidance *activeGuidance = [[TJBActiveCircuitGuidance alloc] initWithChainTemplate: chainTemplate
                                                             realizedChainCorrespondingToChainTemplate: realizedChainSkeleton
                                                                               circuitActiveUpdatingVC: circuitActiveUpdating.circuitActiveUpdatingVC
                                                                                           wasRestored: NO
                                                                                     personalRecordsVC: personalRecordsVC];
    
    [activeGuidance.tabBarItem setTitle: @"Guide"];
     
    // circuit reference container VC
    
    TJBCircuitReferenceContainerVC *circuitReference = [[TJBCircuitReferenceContainerVC alloc] initWithChainTemplate: chainTemplate];
    
    [circuitReference.tabBarItem setTitle: @"Goals"];
    
    // tab bar controller
    
    [self setViewControllers: @[activeGuidance,
                                circuitReference,
                                circuitActiveUpdating,
                                personalRecordsVC]];
    
    // tab bar configuration
    
    [self setRestorationPropertiesAndConfigureTabBar];
    
    return self;
}

- (void)setRestorationPropertiesAndConfigureTabBar{
    
    // for restoration
    
    self.restorationClass = [TJBCircuitModeTBC class];
    self.restorationIdentifier = @"TJBCircuitModeTBC";
    
    // tab bar
    
    self.tabBar.translucent = NO;
    
}


#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    //// the child VC's will be added in the decode method. Do all else here
    
    TJBCircuitModeTBC *tbc = [[TJBCircuitModeTBC alloc] init];
    
    // tab bar configuration
    
    [tbc setRestorationPropertiesAndConfigureTabBar];
    
    return tbc;
    
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    //// must encode all child VC's and the selected tab bar index
    
    [super encodeRestorableStateWithCoder: coder];
    
    // child VC's
    
    NSArray *children = self.viewControllers;
    
    [coder encodeObject: children[0]
                 forKey: @"vc1"];
    
    [coder encodeObject: children[1]
                 forKey: @"vc2"];
    
    [coder encodeObject: children[2]
                 forKey: @"vc3"];
    
    [coder encodeObject: children[3]
                 forKey: @"vc4"];
    
    // selected tab bar index
    
    [coder encodeInteger: self.selectedIndex
                  forKey: @"selectedIndex"];
    
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    
    //// must decode all encoded items here.  These assignments must mirror what is done in the normal init method
    
    [super decodeRestorableStateWithCoder: coder];
    
    // child VC's
    
    TJBCircuitActiveUpdatingContainerVC *vc3 = [coder decodeObjectForKey: @"vc3"];
    
    // personal records VC
    
    RealizedSetPersonalRecordVC *vc4 = [coder decodeObjectForKey: @"vc4"];

    TJBActiveCircuitGuidance *vc1 = [coder decodeObjectForKey: @"vc1"];
    
    // the TJBCircuitActiveUpdatingVC is not restored, only its container class is.  Thus, the following assignment must be made here as opposed to in 'decode' type methods (a coded reference to a VC that is not restored will not find the original VC upon decoding)
    
    vc1.circuitActiveUpdatingVC = vc3.circuitActiveUpdatingVC;
    vc1.personalRecordsVC = vc4;
    
    TJBCircuitReferenceContainerVC *vc2 = [coder decodeObjectForKey: @"vc2"];
    
    [vc1.tabBarItem setTitle: @"Active"];
    [vc2.tabBarItem setTitle: @"Targets"];
    [vc3.tabBarItem setTitle: @"Progress"];
    [vc4.tabBarItem setTitle: @"Records"];
    
    [self setViewControllers: @[vc1,
                                vc2,
                                vc3,
                                vc4]];
    
    // selected index
    
    self.selectedIndex = [coder decodeIntegerForKey: @"selectedIndex"];
    
}




@end






































