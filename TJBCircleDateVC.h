//
//  TJBCircleDateVC.h
//  Beast
//
//  Created by Trevor Beasty on 1/26/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJBCircleDateVC : UIViewController

- (instancetype)initWithMainButtonTitle:(NSString *)mainButtonTitle dayTitle:(NSString *)dayTitle size:(CGSize)size hasSelectedAppearance:(BOOL)hasSelectedAppearance isEnabled:(BOOL)isEnabled isCircled:(BOOL)isCircled;

- (void)configureButtonAsSelected;
- (void)configureButtonAsNotSelected;

- (void)configureWithDayTitle:(NSString *)dayTitle buttonTitle:(NSString *)buttonTitle;


@end
