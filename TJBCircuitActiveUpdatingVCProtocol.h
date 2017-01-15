//
//  TJBCircuitActiveUpdatingVCProtocol.h
//  Beast
//
//  Created by Trevor Beasty on 1/15/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

// number selection

#import "TJBNumberSelectionVC.h"

// child VC

@class TJBCircuitActiveUpdatingRowComp;

#import "TJBCircuitActiveUpdatingRowCompProtocol.h"

@protocol TJBCircuitActiveUpdatingVCProtocol <NSObject>

// for keeping track of child VC's

- (void)addChildRowController:(TJBCircuitActiveUpdatingRowComp<TJBCircuitActiveUpdatingRowCompProtocol> *)rowController forExerciseIndex:(int)exerciseIndex;

- (void)didCompleteSetWithExerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex weight:(NSNumber *)weight reps:(NSNumber *)reps setBeginDate:(NSDate *)setBeginDate setEndDate:(NSDate *)setEndDate;

// for making corrections

- (void)enableWeightAndRepsButtonsAndGiveEnabledAppearance;

- (void)disableWeightAndRepsButtonsAndGiveDisabledAppearance;

- (void)didPressUserInputButtonWithType:(NumberType)type chainNumber:(NSNumber *)chainNumber roundNumber:(NSNumber *)roundNumber button:(UIButton *)button;

@end
