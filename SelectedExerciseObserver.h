//
//  SelectedExerciseObserver.h
//  Beast
//
//  Created by Trevor Beasty on 12/12/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TJBExercise;

@protocol SelectedExerciseObserver <NSObject>

- (void)didSelectExercise:(TJBExercise *)exercise;

- (void)newSetSubmitted;

@end
