//
//  TJBWorkoutNavigationHub.h
//  Beast
//
//  Created by Trevor Beasty on 12/12/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// protocols

#import "TJBDateSelectionMaster.h"

@interface TJBWorkoutNavigationHub : UIViewController <TJBDateSelectionMaster>

#pragma mark - Instantiation

- (instancetype)initWithHomeButton:(BOOL)includeHomeButton advancedControlsActive:(BOOL)advancedControlsActive;

#pragma mark - Table View Cell Sizing



@end
