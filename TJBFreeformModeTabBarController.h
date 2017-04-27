//
//  TJBFreeformModeTabBarController.h
//  Beast
//
//  Created by Trevor Beasty on 4/26/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJBExercise; // core data

@interface TJBFreeformModeTabBarController : UITabBarController

- (instancetype)initWithActiveExercise:(TJBExercise *)exercise;

@end
