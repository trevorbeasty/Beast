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

- (instancetype)initWithDayIndex:(NSNumber *)dayIndex dayTitle:(NSString *)dayTitle size:(CGSize)size hasSelectedAppearance:(BOOL)hasSelectedAppearance isEnabled:(BOOL)isEnabled isCircled:(BOOL)isCircled masterController:(TJBWorkoutNavigationHub<TJBDateSelectionMaster> *)masterController representedDate:(NSDate *)representedDate representsHistoricDay:(BOOL)representsHistoricDay;

- (void)configureButtonAsSelected;
- (void)configureButtonAsNotSelected;

- (void)configureWithDayTitle:(NSString *)dayTitle buttonTitle:(NSString *)buttonTitle;

// disabling controls while cell content loads

- (void)configureDisabledAppearance;
- (void)configureEnabledAppearance;

// get rid of dot when all cell content is deleted for the active date

- (void)getRidOfContentDot;


@end
