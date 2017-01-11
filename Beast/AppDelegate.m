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

// willFinishLaunching is called before state restoration methods are called and the opposite is true for didFinishLaunching
// will need the core data model to be loaded before state restoration so that restoration methods can access the requisite managed objects
// may want to consider developing some sort of cache for the immediately requisite managed objects so that performence does not suffer

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    // prevents transition styles from occurring upon state restoration
    [self.window makeKeyAndVisible];
    
    // immediately load the entire core data structure
    [[CoreDataController singleton] persistentContainer];
    
    // core data file path
    NSURL *path = [NSPersistentContainer defaultDirectoryURL];
    NSLog(@"%@", [path absoluteString]);
    
    // root view controller
    TJBWorkoutNavigationHub *wnh = [[TJBWorkoutNavigationHub alloc] init];
    self.window.rootViewController = wnh;
    
    return YES;
}


// the app delegate must opt in to state restoration via the following 2 methods
- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder{
    return NO;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder{
    return NO;
}

- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    // UIKit automatically finds TJBWorkoutNavigation hub as part of its restoration effort (see view controller programming guide)
    return nil;
}






- (void)applicationDidBecomeActive:(UIApplication *)application{
    NSLog(@"application did become active");
}

- (void)applicationWillResignActive:(UIApplication *)application{
    NSLog(@"application will resign active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    NSLog(@"application did enter background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    NSLog(@"application will enter foreground");
}

- (void)applicationWillTerminate:(UIApplication *)application{
    NSLog(@"application will terminate");
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    NSLog(@"application did receive memory warning");
}


@end






















