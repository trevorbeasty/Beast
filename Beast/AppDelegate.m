//
//  AppDelegate.m
//  Beast
//
//  Created by Trevor Beasty on 12/6/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "AppDelegate.h"

#import "TJBChainTemplate+CoreDataProperties.h"
#import "TJBExerciseCategory+CoreDataProperties.h"
#import "TJBExercise+CoreDataProperties.h"

#import "TJBRealizedSetActiveEntryVC.h"
#import "TJBRealizedSetHistoryByDay.h"

#import "CoreDataController.h"

@interface AppDelegate ()

@property (nonatomic, strong) CoreDataController *cdc;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // core data controller
    
    self.cdc = [CoreDataController singleton];
    
    // core data file path
    
    NSURL *path = [NSPersistentContainer defaultDirectoryURL];
    NSLog(@"%@", [path absoluteString]);
    
    // root view controller
    
    TJBRealizedSetActiveEntryVC *vc1 = [[TJBRealizedSetActiveEntryVC alloc] init];
    [vc1.tabBarItem setTitle: @"Active Entry"];
    
    TJBRealizedSetHistoryByDay *vc2 = [[TJBRealizedSetHistoryByDay alloc] init];
    [vc2.tabBarItem setTitle: @"Today's History"];
    
    UITabBarController *tbc = [[UITabBarController alloc] init];
    
    [tbc setViewControllers: @[vc1, vc2]];
    tbc.tabBar.translucent = NO;
    
    self.window.rootViewController = tbc;
    
    return YES;
}


@end








