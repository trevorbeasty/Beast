//
//  TJBAssortedUtilities.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBAssortedUtilities.h"

// core data

#import "CoreDataController.h"

@implementation TJBAssortedUtilities

+ (void)nextIndiceValuesForCurrentExerciseIndex:(NSNumber *)currentExerciseIndex currentRoundIndex:(NSNumber *)currentRoundIndex maxExerciseIndex:(NSNumber *)maxExerciseIndex maxRoundIndex:(NSNumber *)maxRoundIndex exerciseIndexReference:(NSNumber *__autoreleasing *)exerciseIndexReference roundIndexReference:(NSNumber *__autoreleasing *)roundIndexReference{
    
    int currentExercise = [currentExerciseIndex intValue];
    int currentRound = [currentRoundIndex intValue];
    
    int maxExercise = [maxExerciseIndex intValue];
    int maxRound = [maxRoundIndex intValue];
    
    BOOL atMaxExerciseIndex = currentExercise == maxExercise;
    BOOL atEndOfCircuit = atMaxExerciseIndex && currentRound == maxRound;
    
    NSNumber *exerciseReturnValue;
    NSNumber *roundReturnValue;
    
    if (atEndOfCircuit){
        
        abort();
        
    } else if(atMaxExerciseIndex){
        
        exerciseReturnValue = [NSNumber numberWithInt: 0];
        *exerciseIndexReference = exerciseReturnValue;
        
        roundReturnValue = [NSNumber numberWithInt: currentRound + 1];
        *roundIndexReference = roundReturnValue;
        
    } else{
        
        exerciseReturnValue = [NSNumber numberWithInt: currentExercise + 1];
        *exerciseIndexReference = exerciseReturnValue;
        
    }

}

+ (BOOL)previousExerciseAndRoundIndicesForCurrentExerciseIndex:(int)currentExerciseIndex currentRoundIndex:(int)currentRoundIndex numberOfExercises:(int)numberOfExercises numberOfRounds:(int)numberOfRounds roundIndexReference:(NSNumber *__autoreleasing *)roundIndexReference exerciseIndexReference:(NSNumber *__autoreleasing *)exerciseIndexReference{
    
    //// give the previous exercise and round index based on the given parameters.  Returns NO if there is no previous exercise/round index, YES otherwise
    
    BOOL atFirstRound = currentRoundIndex == 0;
    BOOL atFirstExercise = currentExerciseIndex == 0;
    
    if (atFirstRound && atFirstExercise){
        
        return NO;
        
    } else if (!atFirstExercise){
        
        *roundIndexReference = [NSNumber numberWithInt: currentRoundIndex];
        *exerciseIndexReference = [NSNumber numberWithInt: currentExerciseIndex - 1];
        return YES;
        
    } else if (atFirstExercise){
        
        *roundIndexReference = [NSNumber numberWithInt: currentRoundIndex - 1];
        *exerciseIndexReference = [NSNumber numberWithInt: numberOfExercises - 1];
        return YES;
        
    } else{
        
        abort();
        
    }
    
}

+ (NSOrderedSet<TJBEndDateComp *> *)previousExerciseSetEndDatesForRealizedChain:(TJBRealizedChain *)realizedChain currentExerciseIndex:(int)currentExerciseIndex{
    
    //// return a set of previous set end date components based on the passed-in realized chain and exercise index
    
    int numberOfExercises = realizedChain.numberOfExercises;
    
    BOOL atFirstExercise = currentExerciseIndex == 0;
    
    int previousExerciseIndex;
    
    if (atFirstExercise){
        
        previousExerciseIndex = numberOfExercises - 1;
        
    } else{
        
        previousExerciseIndex = currentExerciseIndex - 1;
        
    }
    
    return realizedChain.setEndDateArrays[previousExerciseIndex].dates;
    
}

@end







































