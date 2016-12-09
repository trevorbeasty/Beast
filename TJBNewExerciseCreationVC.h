//
//  TJBNewExerciseCreationVC.h
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBNewExerciseCreationDelegate.h"

@interface TJBNewExerciseCreationVC : UIViewController

@property (nonatomic, strong) UIViewController <NewExerciseCreationDelegate> *associateVC;

@end
