//
//  TJBCircuitActiveUpdatingVCProtocol.h
//  Beast
//
//  Created by Trevor Beasty on 1/15/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

// core data

//#import "CoreDataController.h"

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

@end
