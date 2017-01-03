//
//  CircuitDesignRowComponent.h
//  Beast
//
//  Created by Trevor Beasty on 12/15/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBCircuitTemplateUserInputDelegate.h"
#import "RowComponentActiveUpdatingProtocol.h"

@class TJBCircuitTemplateGeneratorVC;
@class TJBChainTemplate;

@interface CircuitDesignRowComponent : UIViewController <RowComponentActiveUpdatingProtocol>

@property (weak, nonatomic) IBOutlet UILabel *roundLabel;

- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound roundNumber:(NSNumber *)roundNumber masterController:(TJBCircuitTemplateGeneratorVC <TJBCircuitTemplateUserInputDelegate> *)masterController chainNumber:(NSNumber *)chainNumber supportsUserInput:(BOOL)supportsUserInput chainTemplate:(TJBChainTemplate *)chainTemplate valuesPopulatedDuringWorkout:(BOOL)valuesPopulatedDuringWorkout;

@end
