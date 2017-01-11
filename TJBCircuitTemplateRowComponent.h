//
//  TJBCircuitTemplateRowComponent.h
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJBCircuitTemplateVC;

#import "TJBCircuitTemplateVCProtocol.h"

#import "TJBCircuitTemplateRowComponentProtocol.h"

@interface TJBCircuitTemplateRowComponent : UIViewController <TJBCircuitTemplateRowComponentProtocol>

- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound roundNumber:(NSNumber *)roundNumber masterController:(TJBCircuitTemplateVC <TJBCircuitTemplateVCProtocol> *)masterController chainNumber:(NSNumber *)chainNumber;

@end
