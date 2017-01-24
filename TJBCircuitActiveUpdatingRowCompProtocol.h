//
//  TJBCircuitActiveUpdatingRowCompProtocol.h
//  Beast
//
//  Created by Trevor Beasty on 1/15/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TJBCircuitActiveUpdatingRowCompProtocol <NSObject>

- (void)updateViewsWithWeight:(NSNumber *)weight reps:(NSNumber *)reps;

- (void)updateViewsWithRest:(NSNumber *)rest;

// for making corrections

- (void)enableWeightAndRepsButtonsAndGiveEnabledAppearance;

- (void)disableWeightAndRepsButtonsAndGiveDisabledAppearance;

- (void)disableWeightButtonAndGiveDisabledAppearance;
- (void)disableRepsButtonAndGiveDisabledAppearance;



@end
