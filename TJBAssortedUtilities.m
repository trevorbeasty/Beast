//
//  TJBAssortedUtilities.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBAssortedUtilities.h"

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

@end
