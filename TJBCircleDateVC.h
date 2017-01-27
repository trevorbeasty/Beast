//
//  TJBCircleDateVC.h
//  Beast
//
//  Created by Trevor Beasty on 1/26/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJBCircleDateVC : UIViewController

- (instancetype)initWithMainButtonTitle:(NSString *)mainButtonTitle dayTitle:(NSString *)dayTitle radius:(float)radius center:(CGPoint)center selectedAppearance:(BOOL)selectedAppearance;

- (void)configureButtonAsSelected;
- (void)configureButtonAsNotSelected;


@end
