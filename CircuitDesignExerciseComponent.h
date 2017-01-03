//
//  CircuitDesignExerciseComponent.h
//  Beast
//
//  Created by Trevor Beasty on 12/13/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBCircuitTemplateUserInputDelegate.h"

@class TJBCircuitTemplateGeneratorVC;
@class TJBChainTemplate;

@interface CircuitDesignExerciseComponent : UIViewController

- (instancetype)initWithNumberOfRounds:(NSNumber *)numberOfRounds targetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound chainNumber:(NSNumber *)chainNumber exerciseName:(NSString *)exerciseName masterController:(TJBCircuitTemplateGeneratorVC <TJBCircuitTemplateUserInputDelegate> *)masterController supportsUserInput:(BOOL)supportsUserInput chainTemplate:(TJBChainTemplate *)chainTemplate valuesPopulatedDuringWorkout:(BOOL)valuesPopulatedDuringWorkout;

@end
