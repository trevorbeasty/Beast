//
//  TJBCircuitTemplateExerciseComp.h
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// protocols

#import "TJBCircuitTemplateExerciseComponentProtocol.h"
#import "TJBCircuitTemplateVCProtocol.h"


@class  TJBCircuitTemplateVC;
@class TJBChainTemplate;

@interface TJBCircuitTemplateExerciseComp : UIViewController <TJBCircuitTemplateExerciseComponentProtocol>

//- (instancetype)initWithNumberOfRounds:(NSNumber *)numberOfRounds targetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound chainNumber:(NSNumber *)chainNumber masterController:(TJBCircuitTemplateVC <TJBCircuitTemplateVCProtocol> *)masterController;

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate exerciseIndex:(int)exerciseIndex masterController:(TJBCircuitTemplateVC<TJBCircuitTemplateVCProtocol> *)masterController;

@end
