//
//  TJBActiveRoutineExerciseItemVC.h
//  Beast
//
//  Created by Trevor Beasty on 2/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJBActiveRoutineExerciseItemVC : UIViewController

- (instancetype)initWithTitleNumber:(NSNumber *)titleNumber targetExerciseName:(NSString *)targetExerciseName targetWeight:(NSNumber *)targetWeight targetReps:(NSNumber *)targetReps previousEntries:(NSArray *)previousEntries;

@end
