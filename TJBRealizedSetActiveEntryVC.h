//
//  TJBRealizedSetActiveEntryVC.h
//  Beast
//
//  Created by Trevor Beasty on 12/8/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SelectedExerciseObserver.h"

@interface TJBRealizedSetActiveEntryVC : UIViewController

@property (nonatomic, weak) UIViewController<SelectedExerciseObserver> *personalRecordVC;

@end
