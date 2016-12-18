//
//  CircuitDesignRowComponent.h
//  Beast
//
//  Created by Trevor Beasty on 12/15/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBNumberSelectionDelegate.h"
#import "TJBCircuitTemplateUserInputDelegate.h"

@class TJBCircuitTemplateGeneratorVC;

@interface CircuitDesignRowComponent : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *roundLabel;

@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;
@property (nonatomic, strong) NSNumber *roundNumber;
@property (nonatomic, strong) NSNumber *chainNumber;

@property (nonatomic, strong) TJBCircuitTemplateGeneratorVC <TJBNumberSelectionDelegate> *masterController;

- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound roundNumber:(NSNumber *)roundNumber masterController:(TJBCircuitTemplateGeneratorVC <TJBNumberSelectionDelegate, TJBCircuitTemplateUserInputDelegate> *)masterController chainNumber:(NSNumber *)chainNumber;

@end
