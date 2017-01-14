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

// core data

#import "CoreDataController.h"

@interface TJBCircuitModeTBC () 

@end

@implementation TJBCircuitModeTBC

#pragma mark - Instantiation

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    self = [super init];
    
    // create a skeleton realized chain from the chainTemplate parameter
    // all tab bar child VC's will be configured using these two objects
    
    TJBRealizedChain *realizedChainSkeleton = [[CoreDataController singleton] createAndSaveSkeletonRealizedChainForChainTemplate: chainTemplate];
    
    // active circuit guidance VC
    
    TJBActiveCircuitGuidance *activeGuidance = [[TJBActiveCircuitGuidance alloc] initWithChainTemplate: chainTemplate
                                                             realizedChainCorrespondingToChainTemplate: realizedChainSkeleton
                                                                                           wasRestored: NO];
    
    [activeGuidance.tabBarItem setTitle: @"Guide"];
    
    // circuit reference container VC
    
    TJBCircuitReferenceContainerVC *circuitReference = [[TJBCircuitReferenceContainerVC alloc] initWithChainTemplate: chainTemplate];
    
    [circuitReference.tabBarItem setTitle: @"Goals"];
    
    // circuit active updating container VC
    
    TJBCircuitActiveUpdatingContainerVC *circuitActiveUpdating = [[TJBCircuitActiveUpdatingContainerVC alloc] initWithRealizedChain: realizedChainSkeleton];
    
    [circuitActiveUpdating.tabBarItem setTitle: @"Progress"];
    
    // tab bar controller
    
    [self setViewControllers: @[activeGuidance,
                                circuitReference,
                                circuitActiveUpdating]];
    
    self.tabBar.translucent = NO;
    
    return self;
}

- (void)setRestorationProperties{
    
    // for restoration
    
    self.restorationClass = [TJBCircuitModeTBC class];
    self.restorationIdentifier = @"TJBCircuitModeTBC";
    
    // general
//    
//    self.tabBar.translucent = NO;
}


//#pragma mark - <UIViewControllerRestoration>
//
//+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
//    TJBCircuitModeTBC *tbc = [[TJBCircuitModeTBC alloc] init];
//    
//    // for restoration
//    
//    [tbc configureCommonAttributes];
//    
//    return tbc;
//}
//
//- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
//    
//    [super encodeRestorableStateWithCoder: coder];
//    
//    NSArray *children = self.viewControllers;
//    
//    [coder encodeObject: children[0]
//                 forKey: @"vc1"];
//    [coder encodeObject: children[1]
//                 forKey: @"vc2"];
//    [coder encodeObject: children[2]
//                 forKey: @"vc3"];
//    
//    [coder encodeInteger: self.selectedIndex
//                  forKey: @"selectedIndex"];
//}
//
//- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
//    
//    [super decodeRestorableStateWithCoder: coder];
//    
//    [self configureCommonAttributes];
//    
//    TJBActiveCircuitGuidance *vc1 = [coder decodeObjectForKey: @"vc1"];
//    
//    TJBCircuitTemplateGeneratorVC *vc2 = [coder decodeObjectForKey: @"vc2"];
//    
//    TJBCircuitTemplateGeneratorVC *vc3 = [coder decodeObjectForKey: @"vc3"];
//    
//    [vc1.tabBarItem setTitle: @"Active"];
//    [vc2.tabBarItem setTitle: @"Targets"];
//    [vc3.tabBarItem setTitle: @"Progress"];
//    
//    [vc3 loadViewIfNeeded];
//    
//    [self setViewControllers: @[vc1,
//                               vc2,
//                               vc3]];
//    
//    self.selectedIndex = [coder decodeIntegerForKey: @"selectedIndex"];
//}




@end






































