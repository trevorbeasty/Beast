//
//  AppDelegate.m
//  Beast
//
//  Created by Trevor Beasty on 12/6/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "AppDelegate.h"

//#import "TJBExerciseCategory+CoreDataProperties.h"
//#import "TJBExercise+CoreDataProperties.h"

// core data

#import "CoreDataController.h"

// root view controller

#import "TJBLiftOptionsVC.h"

// local notifications

#import <UserNotifications/UserNotifications.h>

// stopwatch

#import "TJBStopwatch.h"


@interface AppDelegate () <UNUserNotificationCenterDelegate>


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
    
    TJBLiftOptionsVC *vc = [[TJBLiftOptionsVC alloc] init];
    self.window.rootViewController = vc;
    
//    NSLog(@"lift options restoration ID: %@", restor)
    
    // register as delegate of UNUserNotificationCenter
    
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    
    return YES;
    
}

#pragma mark - State Restoration


// the app delegate must opt in to state restoration via the following 2 methods
- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder{
    
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder{
    
    return YES;
}

- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    return nil;
    
}

#pragma mark - App Execution State

- (void)applicationDidEnterBackground:(UIApplication *)application{
    
    NSLog(@"app entered background");
    
}





#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{

    UIViewController *activeVC = [self topViewController];
    
    NSNumber *alertTiming = [TJBStopwatch singleton].alertTiming;
    NSString *formattedAlertTiming = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [alertTiming intValue]];
    NSString *alertMessage = [NSString stringWithFormat: @"Your next set will begin in %@. Please prepare yourself", formattedAlertTiming];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Timer Alert"
                                                                   message: alertMessage
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                     style: UIAlertActionStyleDefault
                                                   handler: nil];
    
    [alert addAction: action];
    
    [activeVC presentViewController: alert
                           animated: YES
                         completion: nil];
    
}

#pragma mark - View Controller Hierarchy

- (UIViewController *)topViewController{
    
    return [self topViewController: self.window.rootViewController];
    
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController{
    
    if (rootViewController.presentedViewController == nil){
        
        return  rootViewController;
        
    }
    
    if ([rootViewController.presentedViewController isKindOfClass: [UINavigationController class]]){
        
        UINavigationController *navCon = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastVC = [[navCon viewControllers] lastObject];
        return [self topViewController: lastVC];
        
    }
    
    UIViewController *presentedVC = rootViewController.presentedViewController;
    return [self topViewController: presentedVC];
    
}


@end






















