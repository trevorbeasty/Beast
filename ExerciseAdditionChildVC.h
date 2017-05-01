//
//  ExerciseAdditionChildVC.h
//  Beast
//
//  Created by Trevor Beasty on 4/30/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CoreDataController.h" // core data

typedef void (^CancelCallback)(void);
typedef void (^NewExerciseCallback)(TJBExercise *);

@interface ExerciseAdditionChildVC : UIViewController

#pragma mark - Instantiation

- (instancetype)initWithSelectedCategory:(TJBExerciseCategoryType)categoryType exerciseAddedCallback:(NewExerciseCallback)eaCallback cancelCallback:(CancelCallback)cCallback;


#pragma mark - Recycling

- (void)refreshWithSelectedExerciseCategory:(TJBExerciseCategoryType)ect;

#pragma mark - Keyboard

- (void)makeTextFieldBecomeFirstResponder;
- (void)makeTextFieldResignFirstResponder;


@end
