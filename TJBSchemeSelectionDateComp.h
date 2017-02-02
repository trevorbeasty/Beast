//
//  TJBSchemeSelectionDateComp.h
//  Beast
//
//  Created by Trevor Beasty on 2/2/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// master controller

@class NewOrExistinigCircuitVC;
#import "TJBSchemeSelectionDateCompDelegate.h"

@interface TJBSchemeSelectionDateComp : UIViewController

- (instancetype)initWithMonthString:(NSString *)monthString representedDate:(NSDate *)representedDate index:(NSNumber *)index isEnabled:(BOOL)isEnabled isCircled:(BOOL)isCircled hasSelectedAppearance:(BOOL)hasSelectedAppearance size:(CGSize)size masterController:(NewOrExistinigCircuitVC<TJBSchemeSelectionDateCompDelegate> *)masterController;

- (void)configureAsSelected;
- (void)configureAsNotSelected;

@end
