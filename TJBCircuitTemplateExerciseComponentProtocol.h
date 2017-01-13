//
//  TJBCircuitTemplateExerciseComponentProtocol.h
//  Beast
//
//  Created by Trevor Beasty on 1/13/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TJBExercise;

@protocol TJBCircuitTemplateExerciseComponentProtocol <NSObject>

- (void)updateViewsWithUserSelectedExercise:(TJBExercise *)exercise;

@end
