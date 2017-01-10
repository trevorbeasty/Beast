//
//  TJBCircuitTemplateExerciseComp.h
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// delegate methods

#import "TJBCircuitTemplateUserInputDelegate.h"

@class  TJBCircuitTemplateVC;

@interface TJBCircuitTemplateExerciseComp : UIViewController

- (instancetype)initWithNumberOfRounds:(NSNumber *)numberOfRounds targetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound chainNumber:(NSNumber *)chainNumber masterController:(TJBCircuitTemplateVC <TJBCircuitTemplateUserInputDelegate> *)masterController;

@end
