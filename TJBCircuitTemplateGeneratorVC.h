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

typedef enum{
    TemplateType,
    ReferenceType,
    ActiveUpdatingType
} TJBCircuitTemplateType;

@class TJBChainTemplate;

@interface TJBCircuitTemplateGeneratorVC : UIViewController <TJBCircuitTemplateUserInputDelegate>

// init methods
- (instancetype)initReferenceTypeWithChainTemplate:(TJBChainTemplate *)chainTemplate;

- (instancetype)initTemplateTypeWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound numberOfExercises:(NSNumber *)numberOfExercises numberOfRounds:(NSNumber *)numberOfRounds name:(NSString *)name;

- (instancetype)initActiveUpdatingTypeWithChainTemplate:(TJBChainTemplate *)chainTemplate;

// other
- (BOOL)doesNotSupportUserInputAndIsPopulatingValuesDuringWorkout;

@end
