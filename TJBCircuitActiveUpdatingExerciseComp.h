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

@interface TJBCircuitActiveUpdatingExerciseComp : UIViewController

- (instancetype)initWithNumberOfRounds:(NSNumber *)numberOfRounds targetsVaryByRound:(NSNumber *)targetsVaryByRound chainNumber:(NSNumber *)chainNumber exercise:(TJBExercise *)exercise weightData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)weightData repsData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)repsData setBeginDates:(NSOrderedSet<TJBBeginDateComp *> *)setBeginDates setEndDates:(NSOrderedSet<TJBEndDateComp *> *)setEndDates maxExerciseIndexToFill:(NSNumber *)maxExerciseIndexToFill maxRoundIndexToFill:(NSNumber *)maxRoundIndexToFill;

@end
