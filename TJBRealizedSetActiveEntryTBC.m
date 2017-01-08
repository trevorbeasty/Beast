//
//  TJBRealizedSetActiveEntryTBC.m
//  Beast
//
//  Created by Trevor Beasty on 1/6/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBRealizedSetActiveEntryTBC.h"

#import "TJBRealizedSetActiveEntryVC.h"
#import "TJBRealizedSetHistoryByDay.h"
#import "RealizedSetPersonalRecordVC.h"

@interface TJBRealizedSetActiveEntryTBC () <UIViewControllerRestoration>

@end

@implementation TJBRealizedSetActiveEntryTBC

#pragma mark - Instantiation

- (instancetype)initWithoutChildViewControllers{
    self = [super init];
    
    // for restoration
    self.restorationIdentifier = @"TJBRealizedSetActiveEntryTBC";
    self.restorationClass = [TJBRealizedSetActiveEntryTBC class];
    
    self.tabBar.translucent = NO;
    
    return self;
}

- (instancetype)initWithChildViewControllers{
    self = [super init];
    
    // for restoration
    self.restorationIdentifier = @"TJBRealizedSetActiveEntryTBC";
    self.restorationClass = [TJBRealizedSetActiveEntryTBC class];
    
    // child VC's
    TJBRealizedSetActiveEntryVC *vc1 = [[TJBRealizedSetActiveEntryVC alloc] init];
    [vc1.tabBarItem setTitle: @"Active Entry"];
    
    TJBRealizedSetHistoryByDay *vc2 = [[TJBRealizedSetHistoryByDay alloc] init];
    [vc2.tabBarItem setTitle: @"Today's Log"];

    RealizedSetPersonalRecordVC *vc3 = [[RealizedSetPersonalRecordVC alloc] init];
    [vc3.tabBarItem setTitle: @"Personal Records"];
    
    vc1.personalRecordVC = vc3;
    
    [self setViewControllers: @[vc1,
                               vc2,
                                vc3]];
    self.tabBar.translucent = NO;
    
    return self;
}

#pragma mark - View Life Cycle


#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{

    TJBRealizedSetActiveEntryTBC *tbc = [[TJBRealizedSetActiveEntryTBC alloc] initWithoutChildViewControllers];
    
    // for restoration
    tbc.restorationIdentifier = @"TJBRealizedSetActiveEntryTBC";
    tbc.restorationClass = [TJBRealizedSetActiveEntryTBC class];
    
    return tbc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    [super encodeRestorableStateWithCoder: coder];
    
    [coder encodeInteger: self.selectedIndex
                  forKey: @"selectedIndex"];
    
    // child VC's
    [coder encodeObject: self.viewControllers[0]
                 forKey: @"vc1"];
    [coder encodeObject: self.viewControllers[1]
                 forKey: @"vc2"];
    [coder encodeObject: self.viewControllers[2]
                 forKey: @"vc3"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    [super decodeRestorableStateWithCoder: coder];
    
    // child VC's
    TJBRealizedSetActiveEntryVC *vc1 = [coder decodeObjectForKey: @"vc1"];
    [vc1.tabBarItem setTitle: @"Active Entry"];
    
    TJBRealizedSetHistoryByDay *vc2 = [coder decodeObjectForKey: @"vc2"];
    [vc2.tabBarItem setTitle: @"Today's Log"];
    
    RealizedSetPersonalRecordVC *vc3 = [coder decodeObjectForKey: @"vc3"];
    [vc3.tabBarItem setTitle: @"Personal Records"];
    
    vc1.personalRecordVC = vc3;
    
    [self setViewControllers: @[vc1,
                                vc2,
                                vc3]];
    self.tabBar.translucent = NO;
    
    self.selectedIndex = [coder decodeIntegerForKey: @"selectedIndex"];
}

@end









































