//
//  AppDelegate.m
//  Beast
//
//  Created by Trevor Beasty on 12/6/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "AppDelegate.h"

#import "TJBExerciseCategory+CoreDataProperties.h"
#import "TJBExercise+CoreDataProperties.h"

#import "TJBWorkoutNavigationHub.h"

#import "CoreDataController.h"

@interface AppDelegate ()


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // core data file path
    
    NSURL *path = [NSPersistentContainer defaultDirectoryURL];
    NSLog(@"%@", [path absoluteString]);
    
    // root view controller
    
    TJBWorkoutNavigationHub *wnh = [[TJBWorkoutNavigationHub alloc] init];
    
    self.window.rootViewController = wnh;
    
    return YES;
}


@end








