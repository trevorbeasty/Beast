//
//  TJBCircuitModeTBC.m
//  Beast
//
//  Created by Trevor Beasty on 1/8/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitModeTBC.h"

#import "TJBCircuitTemplateGeneratorVC.h"
#import "TJBActiveCircuitGuidance.h"

#import "TJBChainTemplate+CoreDataProperties.h"

@interface TJBCircuitModeTBC () <UIViewControllerRestoration>

@end

@implementation TJBCircuitModeTBC

#pragma mark - Instantiation

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    // vc with 'active updating chain' type
    
    TJBCircuitTemplateGeneratorVC *vc3 = [[TJBCircuitTemplateGeneratorVC alloc] initActiveUpdatingTypeWithChainTemplate: chainTemplate];
    
    // need to load the view ahead of time so that it can be ammended without the user first directly accessing it
    [vc3 loadViewIfNeeded];
    
    // active circuit guidance vc
    
    TJBActiveCircuitGuidance *vc1 = [[TJBActiveCircuitGuidance alloc] initWithChainTemplate: chainTemplate
                                                                   circuitTemplateGenerator: vc3];
    
    // vc with 'reference chain' type
    
    TJBCircuitTemplateGeneratorVC *vc2 = [[TJBCircuitTemplateGeneratorVC alloc] initReferenceTypeWithChainTemplate: chainTemplate];
    
    // additional configuration
    
    [vc1.tabBarItem setTitle: @"Active"];
    [vc2.tabBarItem setTitle: @"Targets"];
    [vc3.tabBarItem setTitle: @"Progress"];
    
    // tab bar controller
    
    self = [super init];
    
    [self setViewControllers: @[vc1,
                                vc2,
                                vc3]];
    
    // for restoration
    
    [self configureCommonAttributes];
    
    return self;
}

- (void)configureCommonAttributes{
    
    // for restoration
    
    self.restorationClass = [TJBCircuitModeTBC class];
    self.restorationIdentifier = @"TJBCircuitModeTBC";
    
    // general
    
    self.tabBar.translucent = NO;
}


#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    TJBCircuitModeTBC *tbc = [[TJBCircuitModeTBC alloc] init];
    
    // for restoration
    
    [tbc configureCommonAttributes];
    
    return tbc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super encodeRestorableStateWithCoder: coder];
    
    NSArray *children = self.viewControllers;
    
    [coder encodeObject: children[0]
                 forKey: @"vc1"];
    [coder encodeObject: children[1]
                 forKey: @"vc2"];
    [coder encodeObject: children[2]
                 forKey: @"vc3"];
    
    [coder encodeInteger: self.selectedIndex
                  forKey: @"selectedIndex"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super decodeRestorableStateWithCoder: coder];
    
    [self configureCommonAttributes];
    
    TJBActiveCircuitGuidance *vc1 = [coder decodeObjectForKey: @"vc1"];
    
    TJBCircuitTemplateGeneratorVC *vc2 = [coder decodeObjectForKey: @"vc2"];
    
    TJBCircuitTemplateGeneratorVC *vc3 = [coder decodeObjectForKey: @"vc3"];
    
    [vc1.tabBarItem setTitle: @"Active"];
    [vc2.tabBarItem setTitle: @"Targets"];
    [vc3.tabBarItem setTitle: @"Progress"];
    
    [vc3 loadViewIfNeeded];
    
    [self setViewControllers: @[vc1,
                               vc2,
                               vc3]];
    
    self.selectedIndex = [coder decodeIntegerForKey: @"selectedIndex"];
}




@end






































