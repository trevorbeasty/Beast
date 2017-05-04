//
//  AppDelegate.h
//  Beast
//
//  Created by Trevor Beasty on 12/6/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


#pragma mark - API

- (UIViewController *)topViewController;

@end

