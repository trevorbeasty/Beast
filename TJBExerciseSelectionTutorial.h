//
//  TJBExerciseSelectionTutorial.h
//  Beast
//
//  Created by Trevor Beasty on 5/4/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef void (^CancelCallbackBlock)(void);

typedef enum{
    TJBExerciseSelectingTutorial,
    TJBWorkoutLogTutorial,
    TJBRoutineSelectionTutorial
}TJBTutorialType;

@interface TJBExerciseSelectionTutorial : UIViewController

#pragma mark - Instantiation

- (instancetype)initWithCancelCallback:(CancelCallbackBlock)cancelCallback tutorialType:(TJBTutorialType)tutorialType;

@end
