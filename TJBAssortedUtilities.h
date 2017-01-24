//
//  TJBAssortedUtilities.h
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

// core data

@class TJBBeginDateComp;
@class TJBEndDateComp;
@class TJBRealizedChain;

@interface TJBAssortedUtilities : NSObject

+ (BOOL)nextIndiceValuesForCurrentExerciseIndex:(int)currentExerciseIndex currentRoundIndex:(int)currentRoundIndex maxExerciseIndex:(int)maxExerciseIndex maxRoundIndex:(int)maxRoundIndex exerciseIndexReference:(NSNumber **)exerciseIndexReference roundIndexReference:(NSNumber **)roundIndexReference;

+ (BOOL)previousExerciseAndRoundIndicesForCurrentExerciseIndex:(int)currentExerciseIndex currentRoundIndex:(int)currentRoundIndex numberOfExercises:(int)numberOfExercises numberOfRounds:(int)numberOfRounds roundIndexReference:(NSNumber **)roundIndexReference exerciseIndexReference:(NSNumber **)exerciseIndexReference;

+ (NSOrderedSet <TJBEndDateComp *> *)previousExerciseSetEndDatesForRealizedChain:(TJBRealizedChain *)realizedChain currentExerciseIndex:(int)currentExerciseIndex;

+ (NSOrderedSet <TJBBeginDateComp *> *)nextExerciseSetBeginDatesForRealizedChain:(TJBRealizedChain *)realizedChain currentExerciseIndex:(int)currentExerciseIndex;

+ (BOOL)indiceWithExerciseIndex:(int)currentExerciseIndex roundIndex:(int)currentRoundIndex isPriorToReferenceExerciseIndex:(int)referenceExerciseIndex referenceRoundIndex:(int)referenceRoundIndex;

@end
