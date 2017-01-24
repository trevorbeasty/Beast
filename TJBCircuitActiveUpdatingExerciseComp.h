//
//  TJBCircuitActiveUpdatingExerciseComp.h
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// core data

@class TJBNumberTypeArrayComp;
@class TJBExercise;
@class TJBBeginDateComp;
@class TJBEndDateComp;

// master controller

#import "TJBCircuitActiveUpdatingVCProtocol.h"
@class TJBCircuitActiveUpdatingVC;

@interface TJBCircuitActiveUpdatingExerciseComp : UIViewController

- (instancetype)initWithNumberOfRounds:(NSNumber *)numberOfRounds chainNumber:(NSNumber *)chainNumber exercise:(TJBExercise *)exercise firstIncompleteExerciseIndex:(NSNumber *)firstIncompleteExerciseIndex firstIncompleteRoundIndex:(NSNumber *)firstIncompleteRoundIndex weightData:(NSOrderedSet <TJBNumberTypeArrayComp *> *)weightData repsData:(NSOrderedSet <TJBNumberTypeArrayComp *> *)repsData setBeginDatesData:(NSOrderedSet <TJBBeginDateComp *> *)setBeginDatesData setEndDatesData:(NSOrderedSet <TJBEndDateComp *> *)setEndDatesData nextExerciseSetBeginDatesData:(NSOrderedSet <TJBBeginDateComp *> *)nextExerciseSetBeginDatesData numberOfExercises:(NSNumber *)numberOfExercises masterController:(TJBCircuitActiveUpdatingVC<TJBCircuitActiveUpdatingVCProtocol> *)masterController;

@end
