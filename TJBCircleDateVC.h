//
//  TJBCircleDateVC.h
//  Beast
//
//  Created by Trevor Beasty on 1/26/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// master controller

@class TJBWorkoutNavigationHub;
#import "TJBDateSelectionMaster.h"

@interface TJBCircleDateVC : UIViewController

- (instancetype)initWithDayIndex:(NSNumber *)dayIndex dayTitle:(NSString *)dayTitle size:(CGSize)size hasSelectedAppearance:(BOOL)hasSelectedAppearance isEnabled:(BOOL)isEnabled isCircled:(BOOL)isCircled masterController:(TJBWorkoutNavigationHub<TJBDateSelectionMaster> *)masterController representedDate:(NSDate *)representedDate;

- (void)configureButtonAsSelected;
- (void)configureButtonAsNotSelected;

- (void)configureWithDayTitle:(NSString *)dayTitle buttonTitle:(NSString *)buttonTitle;


@end
