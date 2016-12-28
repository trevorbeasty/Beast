//
//  TJBCircuitTemplateGeneratorVC.h
//  Beast
//
//  Created by Trevor Beasty on 12/16/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CircuitDesignExerciseComponent.h"

#import "TJBCircuitTemplateUserInputDelegate.h"

@class TJBChainTemplate;

@interface TJBCircuitTemplateGeneratorVC : UIViewController <TJBCircuitTemplateUserInputDelegate>

- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound numberOfExercises:(NSNumber *)numberOfExercises numberOfRounds:(NSNumber *)numberOfRounds name:(NSString *)name supportsUserInput:(BOOL)supportsUserInput;

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate supportsUserInput:(BOOL)supportsUserInput;

@end
