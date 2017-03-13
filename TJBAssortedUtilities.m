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

+ (BOOL)indiceWithExerciseIndex:(int)currentExerciseIndex roundIndex:(int)currentRoundIndex isPriorToReferenceExerciseIndex:(int)referenceExerciseIndex referenceRoundIndex:(int)referenceRoundIndex{
    
    // return a BOOL indicating if the queried round comes before the reference round
    
    if (currentRoundIndex < referenceRoundIndex){
        
        return YES;
        
    } else if (currentRoundIndex > referenceRoundIndex){
        
        return NO;
        
    } else{
        
        if (currentExerciseIndex < referenceExerciseIndex){
            
            return YES;
            
        } else{
            
            return NO;
            
        }
        
    }
    
}

+ (BOOL)nextIndiceValuesForCurrentExerciseIndex:(int)currentExerciseIndex currentRoundIndex:(int)currentRoundIndex maxExerciseIndex:(int)maxExerciseIndex maxRoundIndex:(int)maxRoundIndex exerciseIndexReference:(NSNumber *__autoreleasing *)exerciseIndexReference roundIndexReference:(NSNumber *__autoreleasing *)roundIndexReference{
    
    //// returns YES if the next round indices exist and NO otherwise.  Also passes back next round indices if they exist via pass by reference
    
    BOOL atMaxRoundIndex = currentRoundIndex == maxRoundIndex;
    BOOL atMaxExerciseIndex = currentExerciseIndex == maxExerciseIndex;
    
    NSNumber *exerciseReturnValue;
    NSNumber *roundReturnValue;
    

    if(atMaxExerciseIndex){
        
        if (atMaxRoundIndex){
            
            exerciseReturnValue = [NSNumber numberWithInt: 0];
            
            roundReturnValue = [NSNumber numberWithInt: currentRoundIndex + 1];
            
            *exerciseIndexReference = exerciseReturnValue;
            *roundIndexReference = roundReturnValue;
            
            return NO;
            
        } else{
            
            exerciseReturnValue = [NSNumber numberWithInt: 0];
            
            roundReturnValue = [NSNumber numberWithInt: currentRoundIndex + 1];
            
        }
        
    } else{
            
        exerciseReturnValue = [NSNumber numberWithInt: currentExerciseIndex + 1];
        
        roundReturnValue = [NSNumber numberWithInt: currentRoundIndex];
            
    }
    
    *exerciseIndexReference = exerciseReturnValue;
    *roundIndexReference = roundReturnValue;

    return YES;
    
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

+ (NSOrderedSet<TJBBeginDateComp *> *)nextExerciseSetBeginDatesForRealizedChain:(TJBRealizedChain *)realizedChain currentExerciseIndex:(int)currentExerciseIndex{
    
    int numberOfExercises = realizedChain.numberOfExercises;
    
    BOOL atLastExercise = currentExerciseIndex == numberOfExercises - 1;
    
    int nextExerciseIndex;
    
    if (atLastExercise){
        
        nextExerciseIndex = 0;
        
    } else{
        
        nextExerciseIndex = currentExerciseIndex + 1;
        
    }
    
    return realizedChain.setBeginDateArrays[nextExerciseIndex].dates;
    
}

@end







































